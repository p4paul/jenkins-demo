#!/usr/bin/env perl
#
# Perforce Helix TeamHub Trigger Script
#
# @copyright   2018 Perforce Software. All rights reserved.
# @version     <release>/<patch>
#
# This script is used to push Perforce events into Helix TeamHub. This script requires certain
# variables defined to operate correctly (described below).
#
# This script should be executed in one of the following ways:
#
#   hth-trigger.pl -t <type> -d <depotName> -n <repo> -N <repoName> -p <pusher> -r <refName> -o <oldValue> -v <newValue> [-c <config file>]
#
#   hth-trigger.pl -o
#
# Helix TeamHub trigger is meant to be called from a Perforce trigger. It should be placed
# on the Perforce Server machine. Check the output from 'hth-trigger.pl -o' for
# an example configuration that can be copied into Perforce triggers.
#
# The -t <type> specifies the trigger type, currently it must have the following value:
#   graph-push-reference-complete
#
# The -d <depot> specifies the graph depot where the activity occurred.
#
# The -n <repo> specifies the graph depot repo where the activity occurred.
#
# The -N <repoName> specified the graph depot repo name where the activity occurred.
#
# The -p <pusher> specifies Perforce used ID of the pusher.
# The -r <refName> specifies repo reference name of the activity.
#
# The -O <oldValue> specifies old value of the reference.
#
# The -v <newValue> specifies new value of the reference.
#
# The -c <config_file> specifies optional config file to source variables from
# (see below). Anything defined in the <config_file> will override variables
# defined in the default config files (see below).
#
# The -o will output the sample trigger lines that can be copied into Perforce
# triggers.
#
# You can utilize one of the following default configuration files to define the
# variables needed:
#
#   /etc/perforce/hth-trigger.conf
#   /opt/perforce/etc/hth-trigger.conf
#   hth-trigger.conf (in the same directory as this script)
#
# The following config variables are recognized and utilized by the Helix TeamHub trigger
# script:
#
#   HTH_HOST            hostname of your Helix TeamHub instance, with leading http://
#                       or https://
#
#   HTH_COMPANY_KEY     the company key that has the projects for this server
#                       TODO: include link of how to locate out company key
#
#   HTH_API_KEY         the API key used when talking to Helix TeamHub to provide authentication
#                       You must create an admin bot acccount in HTH prior to using this trigger
#                       and provide the API key
#                       https://helixteamhub.cloud/docs/user/bots/
#
#   VERIFY_SSL          either 0 or 1, where 1 will validate the SSL certificate
#                       of the Helix TeamHub web server, and 0 will skip validation
#                       allowing the use of self-signed certificates.
#
# These config variables can also be specified inside this script itself (under
# the "%config" variable below). Note that for the later option, any values
# defined in the default config files (or one specified via -c) will override
# what is set here. In addition, if you replace or update this script to a new
# version, please ensure you preserve your changes.
#
# Example of configuration file:
#
#   HTH_HOST="http://my-hth-host"
#   HTH_API_KEY="MY-HTH-API-KEY"
#   HTH_COMPANY_KEY="MY-HTH-COMPANY-KEY"
#
# HTH_HOST, HTH_COMPANY_KEY, and HTH_API_KEY variables must be specified.
#
# Please report any bugs or feature requests to <support@perforce.com>.

# Specify the fallback config values here. Be aware that they will be overridden
# by values of matching variables in default config files or the one specified
# via -c as described above.

my %config = (
    HTH_HOST        => 'http://my-hth-host',
    HTH_COMANY_KEY  => 'MY-HTH-COMPANY-KEY',
    HTH_API_KEY     => 'MY-HTH-API-KEY',
    VERIFY_SSL      => 1
);

# DO NOT EDIT PAST THIS LINE ------------------------------------------------ #

require 5.008;

use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
use File::Temp qw(tempfile tempdir mktemp);
use Getopt::Std;
use POSIX qw(SIGINT SIG_BLOCK SIG_UNBLOCK);
use Scalar::Util qw(looks_like_number);
use Sys::Syslog;

sub escape_shell_arg ($);
sub run;
sub run_quiet;
sub get_trigger_entries;
sub parse_config;
sub usage (;$);
sub safe_fork;
sub error ($;$$);

# Introspect a little about ourselves and where we live
my $ME        = basename($0);
my $ABS_ME    = abs_path($0);
my $MY_PATH   = dirname($ABS_ME);
my $IS_WIN    = $^O eq 'MSWin32';
my $HAVE_TINY = eval {
    require HTTP::Tiny;
    import HTTP::Tiny;
    1
};

# Setup logging; syslog won't actually connect till we have something to say
openlog($ME, 'nofatal', 0);

# Show short usage if there are no arguments
usage('short') unless scalar @ARGV;

# Parse out command line arguments
my %args;
error('Unknown or invalid argument provided') and usage('short')
    unless getopts('ht:d:n:N:p:r:O:v:c:o', \%args);

# Generate friendlier keys for the commonly used args
@args{qw(type depot repo repoName pusher refName oldValue newValue config_file)} = @args{qw(t d n N p r O v c)};

# Show full usage if help is requested
usage() if $args{h};

# Dump just the trigger entries if -o was passed
print get_trigger_entries() and exit 0 if $args{o};

# Looks like we're doing this for real; ensure we have all the required data
error('No event type supplied') and usage('short')
   unless defined $args{type} && length $args{type};
error('No depot supplied') and usage('short')
   unless defined $args{depot} && length $args{depot};
error('No repo supplied') and usage('short')
   unless defined $args{repo} && length $args{repo};
error('No repoName supplied') and usage('short')
   unless defined $args{repoName} && length $args{repoName};
error('No pusher supplied') and usage('short')
   unless defined $args{pusher} && length $args{pusher};
error('No reference supplied') and usage('short')
   unless defined $args{refName} && length $args{refName};
# error('No oldValue supplied') and usage('short')
#   unless defined $args{oldValue} && length $args{oldValue};
error('No new value supplied') and usage('short')
   unless defined $args{newValue} && length $args{newValue};

# oldValue migght show up someday, if it doesn't replace the default %oldValue% with an empty string
if ($args{oldValue} eq '%oldValue%') {
    $args{oldValue} = '';
}

# Parse any config files
parse_config();

# Sanity check global variables we need for posting events to HTH.
if (!length $config{HTH_HOST} || $config{HTH_HOST} eq 'http://my-hth-host') {
    error(
        "HTH_HOST is not set properly; please contact your administrator.",
        "$args{type}: HTH_HOST empty or default"
    );
    exit 1;
}
if (!length $config{HTH_COMPANY_KEY} || $config{HTH_COMPANY_KEY} eq 'MY-HTH-COMPANY-KEY') {
    error(
        "HTH_COMPANY_KEY is not set properly; please contact your administrator.",
        "$args{type}: HTH_COMPANY_KEY empty or default"
    );
    exit 1;
}
if (!length $config{HTH_API_KEY} || $config{HTH_API_KEY} eq 'MY-HTH-API-KEY') {
    error(
        "HTH_API_KEY is not set properly; please contact your administrator.",
        "$args{type}: HTH_API_KEY empty or default"
    );
    exit 1;
}

# For other HTH trigger types, post the event to HTH asynchronously (detach to the background).
# Note we don't presently background on Windows; only *nix systems.
if (!$IS_WIN) {
    # Flush output immediately; no buffering.
    local $| = 1;

    # Safely fork the process - returns child pid to the parent process and 0
    # to the child process.
    my $pid;
    eval { $pid = safe_fork(); };
    error("Failed to fork: $@") and exit 1 if $@;

    # Exit parent.
    exit 0 if $pid;

    # Close STDOUT and STDERR to allow detaching.
    if ($args{type} ne "ping") {
        close STDOUT;
        close STDERR;
    }
}

# The host really really aught to lead with http already, but add it if needed.
$config{HTH_HOST} = 'http://' . $config{HTH_HOST}
    if $config{HTH_HOST} !~ /^http/;

# the POST format for HTH
# /api/events
# Authorization: hth.company_key='aa071c109a5153671df0d511a2cb6e15',account_key='e2de6b7abcc62bd426ad52f82bc9bb96
# {  target: "push", type: "graph-push-ref-complete", depot: "depot", repo: "repo", repoName: "repoName", pusher: "pusher", ref: "refName", oldValue: "oldValue", newValue: "newValue"}

# We assume HTH_HOST, HTH_COMPANY_KEY, and HTH_API_KEY are properly set at this point.
my $HTH_REQUEST = "$config{HTH_HOST}/api/events";

# make the auth string
my $auth_data = "hth.company_key=\'$config{HTH_COMPANY_KEY}\',account_key=\'$config{HTH_API_KEY}\'";
error($auth_data);
# HTH accepts the POST data in a JSON format
my $post_data = "{ \"target\": \"push\", \"type\": \"$args{type}\", \"depot\": \"$args{depot}\", \"repo\": \"$args{repo}\", \"repoName\": \"$args{repoName}\", \"pusher\": \"$args{pusher}\", \"ref\": \"$args{refName}\", \"oldValue\": \"$args{oldValue}\", \"newValue\": \"$args{newValue}\" }";
my $options = { content => $post_data };
# We only expect to be setting Cookies in a test environment.

if (exists $config{COOKIES} && $config{COOKIES} ne '') {
    $options->{headers} = {
        'Authorization' => $auth_data,
        'Content-Type' => 'application/json',
        'Cookie' => $config{COOKIES}
    };
} else {
    $options->{headers} = {
        'Authorization' => $auth_data,
        'Content-Type' => 'application/json'
    };
}

# Force verification of SSL certificates if VERIFY_SSL is set.
# HTTP::Tiny does not do this by default.
my %attributes;
if ($config{VERIFY_SSL} == 1) {
    $attributes{'verify_SSL'} = 1;
}

my $failure = "";
if ($HAVE_TINY) {
    my $response = HTTP::Tiny->new(%attributes)->post($HTH_REQUEST, $options);
    if ($response->{status} == 599 && $config{VERIFY_SSL} == 1) {
        $failure = "Error: ($response->{status}/$response->{reason}) (probably invalid SSL certificate) trying to post [$post_data] to [$HTH_REQUEST]";
    } elsif ($response->{status} != 200) {
        $failure = "Error: ($response->{status}/$response->{reason}) trying to post [$post_data] to [$HTH_REQUEST]";
    } elsif ($response->{content} ne "") {
        # It's possible to get a 200 back if we're talking to the wrong web server. We expect
        # no content to be returned by the call to HTH, so if we get a 200, but also get
        # content returned (such as "It Works!"), then probably something is wrong.
        $failure = "Error: Unexpected content returned by [$HTH_REQUEST], is this a Helix TeamHub server? ($response->{content})";
    }
} else {

    # The tiny module is not available, so use curl
    my @curl_cmd=qw(curl --max-time 10 -sS);
    # Disable verification of certificates
    if($config{VERIFY_SSL} != 1){
         push(@curl_cmd,"--insecure");
    }
    if($config{COOKIES}){
        push(@curl_cmd, "--cookie");
        push(@curl_cmd, $config{COOKIES});
    }
    # add the Authorization header
    push(@curl_cmd, '-H' => "Authorization: $auth_data");
    # add content type
    push(@curl_cmd, '-H' => "Content-Type: application/json");
    push(@curl_cmd, "--data",);
    my $output = run(
        @curl_cmd,
        $post_data,
        $HTH_REQUEST
    );

    if ($? != 0) {
        $failure = "Error: ($?) trying to post [$post_data] via [curl] to [$HTH_REQUEST]";
    } elsif ($output) {
        $failure = "Error: Unexpected output from HTH trigger via [curl] to [$HTH_REQUEST]. [$output]";
    }
}

# Always return success to avoid affecting Perforce users, unless this was a ping command.
if ($failure) {
    syslog(3, $failure);
    if ($args{type} eq "ping") {
        printf("$failure\n");
        exit 1;
    }
}
exit 0;

#==============================================================================
# Local Functions
#==============================================================================

# Escapes a string to be used as a shell argument.
sub escape_shell_arg ($) {
    my ($arg) = @_;

    if ($IS_WIN) {
        $arg =~ s/["%!]/ /;
    } else {
        $arg =~ s/\'/\'\\\'/;
    }

    # under Windows, if arg ends with odd number of slashes, add one more
    $arg =~ m/(\\*)$/;
    if ($IS_WIN && length($1) % 2) {
        $arg .= '\\';
    }

    # wrap argument in quotes
    $arg = $IS_WIN
        ? '"'  . $arg . '"'
        : '\''  .$arg . '\'';

    return $arg;
}

# Runs the command specified in parameters and returns the array with lines
# of command output.
sub run {
    my $cmd = join q{ }, map { escape_shell_arg($_) } @_;
    return `$cmd`;
}

sub run_quiet {
    my $cmd = join q{ }, map { escape_shell_arg($_) } @_;
    return $IS_WIN ? `$cmd 1> NUL 2> NUL` : `$cmd &>/dev/null`;
}

# Parses the config files in fixed locations (if they exist) and saves the
# values into %config hash.
sub parse_config {
    my @candidates = (
        !$IS_WIN ? '/etc/perforce/hth-trigger.conf' : '',
        !$IS_WIN ? '/opt/perforce/etc/hth-trigger.conf' : '',
        "$MY_PATH/hth-trigger.conf",
        $args{config_file}
    );

    foreach my $file (@candidates) {
        if (defined $file && length $file && -e $file && open(my $fh, '<', "$file")) {
            while (my $line = <$fh>) {
                chomp $line;
                $line =~ s/#.*$//;
                next unless $line =~ /=/;
                $line =~ s/^\s+|\s+$//g;

                my ($key, $value) = split(/=/, $line, 2);
                $key   =~ s/^['"]?|['"]?\s*$//g; # trim key's whitespace/quotes
                $value =~ s/^\s*['"]?|['"]?$//g; # ditto for the value
                $config{$key} = $value if length $value;
            }
        }
    }
}

# Returns string with formatted trigger lines that can be copied into
# Perforce triggers.
sub get_trigger_entries {
    my $script = $IS_WIN
        ? "%quote%$^X%quote% %quote%$ABS_ME%quote%"
        : "%quote%$ABS_ME%quote%";

    my $config = $args{config_file}
        ? ' -c %quote%'. abs_path($args{config_file}) .'%quote%'
        : '';

    # Define the trigger entries suitable for this script; replace depot
    # paths as appropriate.
    return <<EOT;
	hth.push-ref-complete graph-push-reference-complete //... "$script$config -t graph-push-reference-complete -d %depotName% -n %repo% -N %repoName% -p %pusher% -r %quote%%reference%%quote% -O %oldValue% -v %newValue%"
EOT
}

# Getopts calls this for --help, we redirect to our usage info.
sub HELP_MESSAGE {
    usage();
}

# Prints usage of this script in standard output.
# If optional parameter is passed with false value, it also prints
# additional messages to STDERR.
sub usage (;$) {
    my ($short) = @_;

    print STDERR <<EOU;
Usage: $ME -t <type> -d <depotName> -n <repo> -N <repoName> -p <pusher> -r <refName> -O <oldValue> -v <newValue> [-c <config file>]
       $ME -o
    -t: trigger type, e.g. graph-push-reference-complete
    -d: depot whre the activity happened
    -n: repo where the activity happened
    -N: repo name where the activity happened
    -p: perforce user id of the pusher
    -r: reference name
    -O: old value of the reference
    -v: new value of the reference
    -c: specify optional config file to source variables
    -o: convenience flag to output the trigger lines

EOU

    exit 99 if $short;

    print STDERR <<EOU;
This script is meant to be called from a Perforce trigger. It should be placed
on the Perforce Server machine and the following entries should be added using
'p4 triggers' (use the -o flag to this script to only output these lines):

EOU

    print STDERR get_trigger_entries();

    print STDERR <<EON;
Notes:

* This script requires configuration to be set in an external configuration file
  or directly in the script itself, such as the Helix TeamHub credentials.
  By default, this script will source any of these config file:
    /etc/perforce/hth-trigger.conf
    /opt/perforce/etc/hth-trigger.conf
    hth-trigger.conf (in the same directory as this script)
  Lastly, if -c <config file> is passed, that file will be sourced too.

EON

    exit 99;
}

# Forks the process safely with protection against interrupts while forking.
# Code borrowed from Net::Server::Daemonize.
sub safe_fork {
    # block signal for fork.
    my $sigset = POSIX::SigSet->new(SIGINT);
    POSIX::sigprocmask(SIG_BLOCK, $sigset)
        or die "Can't block SIGINT for fork: [$!]";

    my $pid = fork();
    die "Couldn't fork: [$!]" unless defined $pid;

    $SIG{'INT'} = 'DEFAULT'; # make SIGINT kill us as it did before.

    POSIX::sigprocmask(SIG_UNBLOCK, $sigset)
        or die "Can't unblock SIGINT for fork: [$!]";

    return $pid;
}

# Helper subroutine to log and print a given message into standard error:
# Parameter 1 is the print message (required)
# Parameter 2 is the log message   (optional), when missing, = param 1
# Parameter 3 is the log priority  (optional), defaults to 3 (error)
sub error ($;$$) {
    # Check the input and provide default values for optional parameters.
    my $printError = $_[0];
    my $logError   = defined $_[1] ? $_[1] : $printError;
    my $logLevel   = defined $_[2] ? $_[2] : 3;

    syslog($logLevel, $logError);
    print STDERR "$printError\n";
}

__END__

=head1 NAME

Perforce Helix TeamHub Trigger Script - script for Perforce triggers

=head1 DESCRIPTION

This script is used to push Perforce events into Helix TeamHub.  For full details,
please read the comments in the script file.

=cut

import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;
import org.jenkinsci.plugins.p4.credentials.*;

P4PasswordImpl c = new P4PasswordImpl(CredentialsScope.GLOBAL, "p41666", "p41666", "p4.helix:1666", null, "admin", "0", "0", null, "password")
SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)


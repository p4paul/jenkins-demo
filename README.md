# Jenkins Helix4Git demo
A simple example storing several Git repositories in a Helix server along with Perforce content.

## Instructions
You will need `docker` and `docker-compose` to run this demo.  You can get Docker here for [Mac](https://download.docker.com/mac/stable/Docker.dmg) or [Windows](https://download.docker.com/win/stable/InstallDocker.msi).

1. Clone the demo: `git clone https://github.com/p4paul/jenkins-demo.git`
2. Change into the cloned directory: `cd jenkins-demo`
3. Bring up the instances: `docker-compose up`
4. Wait for the machines to start...

## Services

* Jenkins: http://localhost:3080 
* Helix Swarm: http://localhost:5080  (admin:admin)
* Helix TeamHub: http://localhost:6080  (admin:admin)
* Helix Core: P4PORT=localhost:4000  (admin:admin)

## Usage

Login to Jenkins with user 'admin', password 'admin'.

Git is running https on port 4443; for example, to clone use:

  `git -c http.sslVerify=false clone https://admin:Passw0rd@localhost:4443/plugins/p4-plugin`
  
(the `-c http.sslVerify=false` is needed as the demo does not use a Certificate)

Perforce is on port 4000 with user 'admin' and no password set.  For example, to list repos use:

  `p4 -u admin -p localhost:4000 repos`


## Graph Hybrid demo

This demonstrates how to uses a Stream to combine Git imported repositories and Helix 
Streams in a single project.  The project is based on the Jenkins `p4-plugin` and 
demonstrates how sync graph content and pin it to a tag.

Just build the Jenkins job `graph-hybrid-demo`.


## Graph Trigger demo

This demonstrates how to trigger a Jenkins Job containing git content synced from a 
Helis graph.  The Jenkins job `docker-trigger-demo` is pre-configured, however you will
need to push git content into Perforce and run an initial build.

1. Clone the docker plugin to a local directory `git clone https://github.com/jenkinsci/docker-plugin.git`
2. Change directory `cd docker-plugin`
3. Add remote `git remote add helix https://localhost:4443/plugins/docker-plugin.git`
4. Push repo `git push -u helix master`
5. Build Jenkins job `docker-trigger-demo` (this should pass)
6. Trigger Jenkins job by make a change to the local git repo, commit and push.


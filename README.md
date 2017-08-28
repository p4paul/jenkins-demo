# Jenkins Helix4Git demo
A simple example storing several Git repositories in a Helix server along with Perforce content.

## Instructions
You will need `docker` and `docker-compose` to run this demo.  You can get Docker here for [Mac](https://download.docker.com/mac/stable/Docker.dmg) or [Windows](https://download.docker.com/win/stable/InstallDocker.msi).

1. Clone the demo: `git clone https://github.com/p4paul/jenkins-demo.git`
2. Change into the cloned directory: `cd jenkins-demo`
3. Bring up the instances: `docker-compose up`
4. Wait for the machines to start...
5. Open Jenkins in a browser at http://localhost:4040

## Usage
Login to Jenkins with user 'admin', password 'admin'.

Git is running https on port 4443; for example, to clone use:

  `git clone https://localhost:4443/plugins/p4-plugin`

Perforce is on port 4000 with user 'admin' and no password set.  For example, to list repos use:

  `p4 -u admin -p localhost:4000 repos`


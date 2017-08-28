docker-compose stop
docker-compose rm -f
docker rm -f $(docker ps -a -q) 
docker rmi $(docker images -f "dangling=true" -q)
docker images
ls -lh ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2

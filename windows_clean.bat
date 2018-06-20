@echo off
for /F %%x in ('docker ps -a -q') do docker rm -f %%x
for /F %%b in ('docker images -f "dangling=true" -q') do docker rmi -f %%b
docker images
dir C:\Users\Public\Documents\Hyper-V\Virtual hard disks
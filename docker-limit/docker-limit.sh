#!/bin/bash

menu="
Enter menu you'd like to use :
1. Limit CPU Docker Container
2. Limit Memory Docker Container
3. Monitor Docker Container
4. Reset CPU + Memory limitation
==============================
q: quit the script

=> "

## Function limit memory docker container
function limit_memory_docker() {
    read -r -p "Set memory limit (e.g. 4g, 512m): " memlimit
    read -r -p "Set total memory + swap limit (e.g. 6g, 1g): " swaplimit
    read -r -p "Enter Docker container name or ID to apply limit: " containername
    docker update --memory "$memlimit" --memory-swap "$swaplimit" "$containername" && echo "INFO: Successfully updated memory limits for container: $containername"
}
## Function limit cpu docker container
function limit_cpu_docker() {
    read -r -p "Set CPU cores to allow (e.g. 0-1, 2 for core #2): " cpulimit
    read -r -p "Enter Docker container name or ID to apply limit: " containername
    docker update  --cpuset-cpus "$cpulimit" "$containername" && echo "INFO: Successfully updated CPU core assignment for container: $containername"
}
## Function to reset cpu/memory limitation
function reset_limit_docker() {
    read -r -p "Enter Docker container name or ID you'd like to reset limitation: " containername
    docker update --cpuset-cpus="" --memory="" --memory-swap="" "$containername" && echo "INFO: Successfully reset CPU + Memory limitation for container: $containername"
}

## Function monitor docker container
function monitor_docker() {
    docker container stats
}

## Main Program
while true; do
read -p "$menu" choice
case $choice in
    1) limit_cpu_docker ;;
    2) limit_memory_docker  ;;
    3) monitor_docker ;;
    4) reset_limit_docker ;;
    q) exit 0 ;;
    *) echo "Oops, Invalid choice";;
  esac
done


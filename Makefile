# Makefile to automatize the launch of the project
SHELL := /bin/bash

docker_start :
	bash codes/bash/start_docker.sh

launch_ecs_fargate :
	source codes/bash/start_ecs_fargate.sh && launch_ecs

stop_ecs_fargate :
	source codes/bash/start_ecs_fargate.sh && clean_up

#!/bin/bash 

function build_docker(){
	docker build -t log8415_tp3 . ;
  docker run -it -e AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id) -e AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)  -e AWS_DEFAULT_REGION=$(aws configure get region) -e AWS_SESSION_TOKEN=$(aws configure get aws_session_token)  log8415_tp3 /bin/bash

}

build_docker ; 


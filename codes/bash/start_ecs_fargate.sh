# File to launch the ecs fargate cluster

RED='\033[0;31m'
NC='\033[0m'
# Hard coded VPC, subnets and security groups
vpc_id=vpc-07ebc46cd04431392
subnet1=subnet-0372f740838e0d8da
subnet2=subnet-029d19db9862d9f52
security_group=sg-01a4ada80ecea508a

function show(){
  echo -e "${RED} $1 ${NC}" ;
}

function attach_task_policy(){
  show "Attach task policy";
  aws iam --region us-east-1 attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
}

function cluster_configuration(){
  show "Create cluster configuration";
  ecs-cli configure --cluster ecs-tp3 --default-launch-type FARGATE --config-name ecs-tp3 --region us-east-1 ;
  show "Create CLI profile" ;
  ecs-cli configure profile --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY --session-token $AWS_SESSION_TOKEN  --profile-name ecs-tp3-profile;
}

function create_cluster(){
  show "Create the ECS cluster";
  ecs-cli up --cluster-config ecs-tp3 --force --ecs-profile ecs-tp3-profile --vpc $vpc_id --subnets $subnet1 $subnet2 --security-group $security_group
}

function launch_container(){
  show "Deploy container";
  ecs-cli compose --project-name ecs-tp3 --file codes/fargate/docker-compose.yml --ecs-params codes/fargate/ecs-params.yml  service up --create-log-groups --cluster-config ecs-tp3 --ecs-profile ecs-tp3-profile
}

function show_running_containers(){
  show "Show running containers" ;
  ecs-cli compose --project-name ecs-tp3 --file codes/fargate/docker-compose.yml --ecs-params codes/fargate/ecs-params.yml service ps --cluster-config ecs-tp3 --ecs-profile ecs-tp3-profile
}

function clean_up(){
  show "Delete containers";
  ecs-cli compose --project-name ecs-tp3 --file codes/fargate/docker-compose.yml --ecs-params codes/fargate/ecs-params.yml  service down --cluster-config ecs-tp3 --ecs-profile ecs-tp3-profile;
  show "Delete cluster";
  ecs-cli down --force --cluster-config ecs-tp3 --ecs-profile ecs-tp3-profile;
}


function launch_ecs(){
  attach_task_policy;
  cluster_configuration;
  create_cluster;
  launch_container;
  show_running_containers;
}

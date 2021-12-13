FROM ubuntu
RUN apt-get -y update && apt-get -y upgrade && 	\
    apt-get -y install make python3-pip vim curl && \
    pip install awscli requests fire numpy pandas plotly && \
    # Install AWS ECS CLI
    curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest && \
    chmod +x /usr/local/bin/ecs-cli
#COPY codes/fargate/docker-compose.yml root/fargate/
#COPY codes/fargate/ecs-params.yml root/fargate
COPY Makefile /root/
ADD codes root/codes/
WORKDIR /root

resource "aws_security_group" "worker_group" {
  name_prefix = "worker_group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["10.0.0.0/8"]
  }
}


resource "aws_security_group" "worker_group_two" {
  name_prefix = "worker_group_two"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_security_group" "all_worker_group" {
  name_prefix = "all_worker_group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["10.0.0.0/8"]
  }
}



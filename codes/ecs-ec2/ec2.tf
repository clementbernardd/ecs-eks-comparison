# Ec2 creation
resource "aws_instance" "ec2-instance-tp3" {
  ami                         = "ami-083654bd07b5da81d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.0.id
  associate_public_ip_address = true
  key_name                    = "Ecs-tp3"
#  image_id                  = data.aws_ami.amazon_linux_ecs.id
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_agent.name}"
  vpc_security_group_ids      = [aws_security_group.ecs-tp3-terraform-sg.id]
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("/Ecs-tp3.cer")
    timeout     = "4m"
  }
  user_data                   = "${file("user_data.sh")}"
#  "${data.template_file.user_data.rendered}"

}


data "template_file" "user_data"{
  template = "${file("${path.module}/user_data.sh")}"
}

#data "aws_ami" "ecs_optimized" {
#
#  filter {
#    name   = "name"
#    values = ["amzn-ami-2017.09.l-amazon-ecs-optimized"]
#  }
#}


resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_agent.json}"
}

# Allow EC2 service to assume this role.
data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Give this role the permission to do ECS Agent things.
resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = "${aws_iam_role.ecs_agent.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = "${aws_iam_role.ecs_agent.name}"
}


data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

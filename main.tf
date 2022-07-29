provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

### AWS Launch Configuration -->
resource "aws_launch_template" "BastionLT" {
  //name = "Bastion"
  name_prefix     = "${var.server_name}-"
  image_id        = var.bastion_ami
  instance_type   = var.ec2_instance_type
  security_group_names = [aws_security_group.Bastion_SecurityGroup.name]
  user_data = base64encode(
    templatefile(
      "user_data_bastion.sh.tpl",
      {
        server_name = "${var.server_name}"
      }
    )
    )
  key_name                    = "common"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
### <--

### AWS Auto Scaling Group -->
resource "aws_autoscaling_group" "BastionASG" {
  name                 = "ASG-${aws_launch_template.BastionLT.name}"
  desired_capacity = 1
  min_size             = 1
  max_size             = 1
  availability_zones = ["${aws_default_subnet.default_az1.availability_zone}" , "${aws_default_subnet.default_az2.availability_zone}"]

  launch_template {
    id      = aws_launch_template.BastionLT.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = {
      Name        = "${var.common_tags.Name} in ASG"
      Owner       = var.common_tags.Owner
      project     = var.common_tags.project
      environment = var.common_tags.environment
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
### <--

### AWS Security Group -->
resource "aws_security_group" "Bastion_SecurityGroup" {

  dynamic "ingress" {
    for_each = ["22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["89.19.123.103/32"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
### <--

data "aws_instance" "BastionHost" {
  depends_on = [
    aws_autoscaling_group.BastionASG
  ]
  filter {
    name   = "tag:Name"
    values = ["${var.server_name} in ASG"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }
  
}

### AWS Elastic IP -->
resource "aws_eip" "bastionStaticIp" {
  instance = data.aws_instance.BastionHost.id
  tags     = var.common_tags
}
### <--

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_mq_subnet_group" "mq_subnet_group" {
  name       = "mq_subnet_group"
  subnet_ids = [var.private_subnet_ids[0], var.private_subnet_ids[1]]

  tags = {
    Name = "MQ Subnet Group"
  }
}

resource "aws_mq_broker" "mq" {
  broker_name               = "mq-primary"
  engine_type               = "RabbitMQ"
  engine_version            = "3.13"
  host_instance_type        = "mq.m5.large"
  security_groups           = [aws_security_group.mq_sg.id]
  deployment_mode           = "ACTIVE_STANDBY_MULTI_AZ"
  subnet_ids                = aws_mq_subnet_group.mq_subnet_group.subnet_ids

  user {
    username = vsr.mq_user
    password = vsr.mq_password
  }
}

resource "aws_security_group" "mq_sg" {
  name        = "mq_sg"
  description = "Security Group for MQ Instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
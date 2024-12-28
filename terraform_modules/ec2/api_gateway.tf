# VPC Link Security Group
resource "aws_security_group" "vpc_link" {
  name        = "vpc-link-sg"
  description = "Allow HTTP inbount and outbound to api alb"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTP traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    security_groups = [aws_security_group.apis_lb.id]
    description     = "Allow outbound HTTP traffic to API ALB"
  }
}

# Create an API Gateway VPC Link
resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name              = "vpc-link"
  subnet_ids        = var.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_link.id]
  tags = {
    Name = "vpc-link"
  }
}

# Create an API Gateway HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api"
  protocol_type = "HTTP"
  tags = {
    Name = "http-api"
  }
}

# Create an API integration with VPC Link
resource "aws_apigatewayv2_integration" "vpc_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = aws_lb.apis_lb.dns_name
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link.id

  integration_method = "ANY"
}
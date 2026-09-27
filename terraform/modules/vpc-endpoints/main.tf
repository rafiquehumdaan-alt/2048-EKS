resource "aws_security_group" "endpoint_sg" {
  name        = "2048-vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name = "2048-vpc-endpoint-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "endpoint_ingress" {
  security_group_id            = aws_security_group.endpoint_sg.id
  referenced_security_group_id = var.node_sg_id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = var.private_subnet_ids

  tags = {
    Name = "2048-vpc-endpoint-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = var.private_subnet_ids

  tags = {
    Name = "2048-vpc-endpoint-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = var.private_subnet_ids

  tags = {
    Name = "2048-vpc-endpoint-cloudwatch"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = var.private_subnet_ids

  tags = {
    Name = "2048-vpc-endpoint-ec2"
  }
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = var.private_subnet_ids

  tags = {
    Name = "2048-vpc-endpoint-sts"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = {
    Name = "2048-vpc-endpoint-s3"
  }
}


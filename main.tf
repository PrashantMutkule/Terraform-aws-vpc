variable "vpc_config" {
  description = "Configuration for the VPC."
  type = object({
    cidr_block = string
    name       = string
  })
}

variable "subnet_config" {
  description = "List of subnet definitions."
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name             = string
    public           = optional(bool, false)
  }))
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_config.cidr_block
  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_subnet" "main" {
  for_each = { for idx, subnet in var.subnet_config : idx => subnet }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.value.name
  }
}
locals {
  public_subnets = [for subnet in aws_subnet.main : subnet.id if lookup(subnet.tags, "public", false) == true]
}

locals {
  private_subnets = [for subnet in aws_subnet.main : subnet.id if lookup(subnet.tags, "public", false) == false]
}

#Internet Gateway, if there is atlest one public subnet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  count = length(local.public_subnets) > 0 ? 1 : 0  
  tags = {
    Name = "${var.vpc_config.name}-igw"
  }
}

#routing table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  count = length(local.public_subnets) > 0 ? 1 : 0  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
  tags = {
    Name = "${var.vpc_config.name}-rt"
  }
}

resource "aws_route_table_association" "main" {
  for_each = { for idx, subnet in aws_subnet.main : idx => subnet if lookup(subnet.tags, "public", false) == true }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.main[0].id
}
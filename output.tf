#vpc
output "vpc_id" {
  value = aws_vpc.main.id
}

locals {
  public_subnets = [for subnet in aws_subnet.main : subnet.id if lookup(subnet.tags, "public", false) == true]
}
#subnets
 
output "public_subnet_ids" {
  value = [for subnet in aws_subnet.main : subnet.id if lookup(subnet.tags, "public", false) == true]
}

output "public_subnet_azs" {
  value = [for subnet in aws_subnet.main : subnet.availability_zone if lookup(subnet.tags, "public", false) == true]
}
output "private_subnet_ids" {
  value = [for subnet in aws_subnet.main : subnet.id if lookup(subnet.tags, "public", false) == false]
}

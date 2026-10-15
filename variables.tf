variable "vpc_config" {
    description = "to get the CIDR and Name of the VPC from user"
  type = object({
    cidr_block = string
    name=string  
  })

  validation {
    condition = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "CIDR block must be a valid CIDR notation. -${var.vpc_config.cidr_block}"
  }
}


variable "subnet_config" {
  description = "to get the CIDR, Availability Zone and Name of the Subnet from user"
  type = list(object({
    cidr_block = string
    availability_zone = string
    name = string
    public =  optional(bool, false)
  }))

  validation {
    condition = alltrue([for subnet in var.subnet_config : can(cidrnetmask(subnet.cidr_block))])  
    error_message = "CIDR block must be a valid CIDR notation. -${var.subnet_config[*].cidr_block}"
  }
}
variable "server_name" {
  type    = string
  default = "Bastion"
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "bastion_ami" {
  type    = string
  default = "ami-0cff7528ff583bf9a"
}

variable "common_tags" {
  type = map(any)
  default = {
    Name        = "Bastion"
    Owner       = "serhii.barabash@bini.games"
    project     = "vaPanda"
    environment = "DEV"
  }
}

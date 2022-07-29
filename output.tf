output "Bastion_public_ip" {
  value = aws_eip.bastionStaticIp.public_ip
}

output "BastionHost" {
  value = data.aws_instance.BastionHost.id
}

output "BastionHostState" {
  value = data.aws_instance.BastionHost.instance_state
}

# output "az1" {
#   value = aws_default_subnet.default_az1.availability_zone
# }

# output "az2" {
#   value = aws_default_subnet.default_az2.availability_zone
# }

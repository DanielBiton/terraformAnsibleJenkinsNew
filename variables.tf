
variable "ec2_instance_type" {
  description = "The type of the instance"
  type        = string
  default     = "t2.micro"
}
variable "key_pair_name" {
  description = "The name of the ec2 key pair"
  type        = string
  default     = "devops"
}
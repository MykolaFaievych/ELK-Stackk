variable "allow_ports" {
  type        = list
  default     = ["443", "80"]
}
variable "env" {
  default     = "task1"
}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "asg_name" {}
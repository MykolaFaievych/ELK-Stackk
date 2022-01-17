variable "allow_ports" {
  type        = list
  default     = ["22", "443", "9200", "9300"]
}
variable "env" {
  default = "task1"
}
variable "version-elk" {
  default = "7.10.2"
}
variable "instance_type" {
  default = "t3.medium"
}
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "private_subnet_ids" {}

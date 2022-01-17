variable "allow_ports" {
  type        = list
  default     = ["22", "443", "9200", "5044", "5045"]
}
variable "env" {
  default     = "task1"
}
variable "version-elk" {
  default     = "7.10.2"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "public_subnet_ids" {}
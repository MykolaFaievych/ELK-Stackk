variable "allow_ports" {
  type        = list
  default     = ["22", "80", "8080", "9200", "5061"]
}
variable "version-elk" {
  default = "7.10.2"
}
variable "env" {
  default = "task1"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "vpc_id" {}
variable "public_subnet_ids" {}
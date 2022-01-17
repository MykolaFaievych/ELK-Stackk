module "vpc" {
  source                      = "../aws_modules/vpc_module" 
}

module "elasticsearch" {
  source                     = "../aws_modules/elasticsearch_module"
  version-elk                = "7.16.3"
  env                        = "task2"
  vpc_id                     = "${module.vpc.vpc_id}"
  vpc_cidr_block             = "${module.vpc.vpc_cidr}"
  private_subnet_ids         = "${module.vpc.private_subnet_ids}"
}
module "kibana" {
    source                    = "../aws_modules/kibana_module"
    version-elk               = "7.16.3"
    env                       = "task2"
    vpc_id                    = "${module.vpc.vpc_id}"
    public_subnet_ids         = "${module.vpc.public_subnet_ids}"
}
module "logstash" {
  source                    = "../aws_modules/logstash_module"
  version-elk               = "7.16.3"
  env                       = "task2"
  vpc_id                    = "${module.vpc.vpc_id}"
  vpc_cidr_block            = "0.0.0.0/0"
  public_subnet_ids         = "${module.vpc.public_subnet_ids}"
}
module "filebeat" {
  source                    = "../aws_modules/filebeat_module"
  version-elk               = "7.16.3"
  env                       = "task2"
  vpc_id                    = "${module.vpc.vpc_id}"
  vpc_cidr_block            = "0.0.0.0/0"
  public_subnet_ids         = "${module.vpc.public_subnet_ids}"
}
module "alb" {
  source                    = "../aws_modules/alb_module"
  env                       = "task2"
  vpc_id                    = "${module.vpc.vpc_id}"
  public_subnet_ids         = "${module.vpc.public_subnet_ids}"
  asg_name                  = "${module.kibana.asg_name}"
}
module "route53" {
  source                    = "../aws_modules/route53_module"
  alb-dns_name              = "${module.alb.dns_name}"
  alb-zone_id               = "${module.alb.alb_zone-id}"
}
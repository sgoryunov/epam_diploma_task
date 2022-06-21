output "efs-dns-name" {
    value = module.efs.dns_name
    description = "Efs dns name"
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
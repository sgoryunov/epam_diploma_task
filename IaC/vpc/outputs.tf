output "efs-dns-name" {
    value = module.efs.dns_name
    description = "Efs dns name"
}
output "efs_id" {
  value = module.efs.id
}
output "efs_mount_targets_ids" {
  value = module.efs.mount_target_ids
}
output "vpc_id" {
  value = module.vpc.vpc_id
}

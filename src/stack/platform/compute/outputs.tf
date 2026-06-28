output "ecs_cluster_arn" {
  value = module.ecs_cluster.cluster_arn
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "ecs_log_group_name" {
  value = module.ecs_cluster.log_group_name
}

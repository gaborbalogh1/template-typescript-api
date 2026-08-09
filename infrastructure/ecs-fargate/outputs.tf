output "ecs_service_name" {
  value = module.ecs.service_name
}

output "ecs_task_definition_family" {
  value = module.ecs.task_definition_family
}

output "log_group_name" {
  value = module.ecs.log_group_name
}

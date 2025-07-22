output "alb_dns_name" {
  value = module.ecs_metabase.alb_dns_name
}

output "metabase_url" {
  value = "http://${module.ecs_metabase.alb_dns_name}"
}

output "role_arn" {
  description = "ARN of the IAM role that can run clusterspinner."
  value       = aws_iam_role.this.arn
}

output "parent_zone_ns_records" {
  description = "NS records to delegate the zone from the parent."
  value       = aws_route53_zone.parent_zone.name_servers
}

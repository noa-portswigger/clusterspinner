output "role_name" {
  description = "Name of the IAM role that can run clusterspinner."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM role that can run clusterspinner."
  value       = aws_iam_role.this.arn
}

output "policy_arn" {
  description = "ARN of the customer-managed policy attached to the role."
  value       = aws_iam_policy.clusterspinner.arn
}

output "parent_zone_id" {
  description = "Route53 hosted zone ID."
  value       = aws_route53_zone.parent_zone.zone_id
}

output "parent_zone_ns_records" {
  description = "NS records to delegate the zone from the parent."
  value       = aws_route53_zone.parent_zone.name_servers
}

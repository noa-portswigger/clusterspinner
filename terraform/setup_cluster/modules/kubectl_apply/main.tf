locals {
  apply_args = var.field_manager != "" ? "--server-side --field-manager=${var.field_manager} --force-conflicts" : ""

  command_script = <<-EOT
    set -e
    aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}
    {
    ${var.command}
    } | kubectl apply ${local.apply_args} -f -
  EOT

  manifest_script = <<-EOT
    set -e
    aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}
    kubectl apply ${local.apply_args} -f - <<'MANIFEST'
    ${var.manifest}
    MANIFEST
  EOT

  script = var.command != "" ? local.command_script : local.manifest_script
}

resource "terraform_data" "this" {
  triggers_replace = var.triggers_replace

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = local.script
  }
}

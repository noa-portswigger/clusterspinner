resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argo"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.5.4"

  values = [templatefile("${path.module}/argocd-values.yaml", {
    cluster_name = var.cluster_name
    zone_name    = var.zone_name
  })]

  depends_on = [aws_eks_node_group.bootstrap]
}

resource "terraform_data" "argocd_app" {
  triggers_replace = sha256(templatefile("${path.module}/argo-app.yaml", { cluster_name = var.cluster_name, github_namespace = var.github_namespace }))

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}
      kubectl apply -f - <<'MANIFEST'
      ${templatefile("${path.module}/argo-app.yaml", { cluster_name = var.cluster_name, github_namespace = var.github_namespace })}
      MANIFEST
    EOT
  }

  depends_on = [helm_release.argocd]
}

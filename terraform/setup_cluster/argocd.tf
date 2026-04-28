# SPDX-FileCopyrightText: 2026 The clusterspinner contributors
# SPDX-License-Identifier: MIT

module "argocd_bootstrap" {
  source = "./modules/helm_apply"

  cluster_name     = var.cluster_name
  region           = var.region
  release_name     = "argocd"
  namespace        = "argo"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart_version    = "9.5.4"
  values           = file("${path.module}/argocd-values.yaml")
  triggers_replace = aws_eks_cluster.this.id

  depends_on = [aws_eks_node_group.default, aws_eks_addon.coredns]
}

locals {
  argocd_app_manifest = templatefile("${path.module}/argo-app.yaml", {
    cluster_name     = var.cluster_name
    github_namespace = var.github_namespace
  })
}

module "argocd_app" {
  source = "./modules/kubectl_apply"

  cluster_name     = var.cluster_name
  region           = var.region
  manifest         = local.argocd_app_manifest
  triggers_replace = sha256(local.argocd_app_manifest)

  depends_on = [module.argocd_bootstrap]
}

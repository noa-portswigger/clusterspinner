# SPDX-FileCopyrightText: 2026 The clusterspinner contributors
# SPDX-License-Identifier: MIT

module "cilium_bootstrap" {
  source = "./modules/helm_apply"

  cluster_name  = var.cluster_name
  region        = var.region
  release_name  = "cilium"
  namespace     = "cilium"
  chart         = "oci://quay.io/cilium/charts/cilium"
  chart_version = "1.19.3"
  values = templatefile("${path.module}/cilium-values.yaml", {
    cluster_name     = var.cluster_name
    k8s_service_host = replace(aws_eks_cluster.this.endpoint, "https://", "")
  })
  triggers_replace = aws_eks_cluster.this.id

  depends_on = [aws_eks_cluster.this]
}

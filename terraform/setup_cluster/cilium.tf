locals {
  cilium_chart_version = "1.19.3"
  cilium_values = templatefile("${path.module}/cilium-values.yaml", {
    cluster_name     = var.cluster_name
    k8s_service_host = replace(aws_eks_cluster.this.endpoint, "https://", "")
  })
}

resource "terraform_data" "cilium_bootstrap" {
  triggers_replace = aws_eks_cluster.this.id

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<EOT
set -e
aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}
kubectl create namespace cilium --dry-run=client -o yaml | kubectl apply --server-side --field-manager=argocd-controller -f -
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT
cat > "$TMPFILE" <<'VALUES'
${local.cilium_values}
VALUES
helm template cilium oci://quay.io/cilium/charts/cilium --version ${local.cilium_chart_version} --namespace cilium --include-crds --values "$TMPFILE" | kubectl apply --server-side --field-manager=argocd-controller --force-conflicts -f -
EOT
  }

  depends_on = [aws_eks_cluster.this]
}

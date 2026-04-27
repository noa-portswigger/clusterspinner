resource "helm_release" "cilium" {
  name             = "cilium"
  namespace        = "cilium"
  create_namespace = true
  chart            = "oci://quay.io/cilium/charts/cilium"
  version          = "1.19.3"

  # No nodes exist yet, so operator pods can't schedule until cilium installs CNI on them.
  wait = false

  values = [yamlencode({
    ipam = {
      mode = "eni"
    }
    eni = {
      enabled = true
      subnetTags = {
        "karpenter.sh/discovery" = var.cluster_name
      }
    }
    egressMasqueradeInterfaces = "eth+"
    routingMode                = "native"
    kubeProxyReplacement       = true
    k8sServiceHost             = replace(aws_eks_cluster.this.endpoint, "https://", "")
    k8sServicePort             = "443"
  })]

  depends_on = [aws_eks_cluster.this]
}

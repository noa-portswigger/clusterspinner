# SPDX-FileCopyrightText: 2026 The clusterspinner contributors
# SPDX-License-Identifier: MIT

locals {
  repo_flag = var.repository != "" ? "--repo ${var.repository}" : ""

  # Streams the namespace manifest then the helm-rendered chart manifests
  # to stdout, separated by `---`. kubectl_apply pipes this to
  # `kubectl apply --server-side --field-manager=argocd-controller`,
  # which lets a later argo-cd sync of the same chart take ownership
  # without SSA conflicts.
  command = <<-EOT
    kubectl create namespace ${var.namespace} --dry-run=client -o yaml
    echo "---"
    TMPFILE=$(mktemp)
    trap "rm -f $TMPFILE" EXIT
    cat > "$TMPFILE" <<'VALUES'
    ${var.values}
    VALUES
    helm template ${var.release_name} ${var.chart} ${local.repo_flag} --version ${var.chart_version} --namespace ${var.namespace} --include-crds --values "$TMPFILE"
  EOT
}

module "apply" {
  source = "../kubectl_apply"

  cluster_name     = var.cluster_name
  region           = var.region
  command          = local.command
  field_manager    = "argocd-controller"
  triggers_replace = var.triggers_replace
}

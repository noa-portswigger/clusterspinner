# SPDX-FileCopyrightText: 2026 The clusterspinner contributors
# SPDX-License-Identifier: MIT

variable "cluster_name" {
  type        = string
  description = "EKS cluster name, used for aws eks update-kubeconfig."
}

variable "region" {
  type        = string
  description = "AWS region the cluster runs in."
}

variable "manifest" {
  type        = string
  description = "Static manifest YAML to apply. Mutually exclusive with `command`."
  default     = ""
}

variable "command" {
  type        = string
  description = "Shell snippet whose stdout produces the manifest YAML to apply. Mutually exclusive with `manifest`."
  default     = ""
}

variable "field_manager" {
  type        = string
  description = "If non-empty, applies with --server-side --field-manager=<value> --force-conflicts."
  default     = ""
}

variable "triggers_replace" {
  type        = any
  description = "Value that, when changed, re-runs the provisioner."
}

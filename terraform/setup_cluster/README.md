# Small EKS Cluster with Terraform

This Terraform configuration creates a small Amazon EKS cluster similar to the `eksctl` getting-started guide:

- One VPC
- Two public subnets across two AZs
- Two private subnets across two AZs
- One NAT gateway
- One EKS control plane
- One managed node group with two `t3.small` worker nodes

## Files

- `versions.tf`: Terraform and provider requirements
- `main.tf`: AWS networking, IAM, EKS cluster, node group, and hard-coded defaults
- `outputs.tf`: useful values after apply

## Usage

```bash
cd cluster-terraform
terraform init
terraform plan
terraform apply
```

After apply:

```bash
aws eks update-kubeconfig --region eu-west-2 --name my-cluster
kubectl get nodes
```

## Notes

- The defaults are hard-coded in `main.tf`: region `eu-west-2`, cluster name `noa-deleteme`, and Kubernetes version `1.35`.
- Kubernetes `1.35` is currently the latest standard-support Amazon EKS version on the AWS docs page, with Amazon EKS release date January 27, 2026.
- This stack stores state in S3 at `s3://clusterspinner-state-658786808637-eu-west-2/cluster-terraform/terraform.tfstate`.
- The defaults are intentionally small, but EKS still incurs AWS charges.
- The worker nodes run in private subnets and use a single NAT gateway for outbound access.
- If you want to cut cost further for non-production use, change `node_desired_size` in `main.tf` to `1`.

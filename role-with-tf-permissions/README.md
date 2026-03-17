# IAM Role for Running terraform-eks-small

This Terraform stack creates an IAM role with the permissions needed to apply the EKS stack in `../terraform-eks-small`.

It covers:

- EKS cluster and managed node group lifecycle
- EC2 networking resources used by that stack
- IAM role creation, policy attachment, and `iam:PassRole` for the EKS cluster and node roles
- S3 read/write access for Terraform state in `noa-tf-state-658786808637-eu-west-2-an`

## Usage

```bash
cd role-with-tf-permissions
terraform init
terraform plan
terraform apply
```

## Notes

- The policy is scoped to the resources created by `terraform-eks-small` where AWS supports resource-level permissions.
- Several EC2 networking actions still require `Resource = "*"`, because AWS does not support tighter scoping for those APIs.
- This stack stores state in S3 at `s3://noa-tf-state-658786808637-eu-west-2-an/role-with-tf-permissions/terraform.tfstate`.
- The role policy also grants access to `terraform-eks-small/terraform.tfstate` so the same role can run both stacks.
- The trust principal, role name, policy name, region, and EKS cluster name are hard-coded in `main.tf`.
- If you expand the EKS stack later, expect to add permissions here as well.

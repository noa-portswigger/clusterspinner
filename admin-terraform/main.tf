provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  region           = "eu-west-2"
  role_name        = "terraform-eks-small-runner"
  policy_name      = "terraform-eks-small-runner-policy"
  eks_cluster_names = ["noa-deleteme", "my-cluster", "noa-delete-me"]
  tf_state_bucket   = "noa-tf-state-658786808637-eu-west-2-an"
  tf_state_keys = [
    "cluster-terraform/terraform.tfstate",
    "admin-terraform/terraform.tfstate",
  ]
  trusted_principals = [
    "arn:aws:iam::658786808637:role/pipeline-roles/teleport-administrator-role"
  ]

  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
  ]

  cluster_role_arns     = [for name in local.eks_cluster_names : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${name}-cluster-role"]
  node_role_arns        = [for name in local.eks_cluster_names : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${name}-node-role"]
  ebs_csi_role_arns     = [for name in local.eks_cluster_names : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${name}-ebs-csi-driver"]
  eks_nodegroup_slr_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"
  cluster_arns          = [for name in local.eks_cluster_names : "arn:${data.aws_partition.current.partition}:eks:${local.region}:${data.aws_caller_identity.current.account_id}:cluster/${name}"]
  nodegroup_arns        = [for name in local.eks_cluster_names : "arn:${data.aws_partition.current.partition}:eks:${local.region}:${data.aws_caller_identity.current.account_id}:nodegroup/${name}/*/*"]
  addon_arns            = [for name in local.eks_cluster_names : "arn:${data.aws_partition.current.partition}:eks:${local.region}:${data.aws_caller_identity.current.account_id}:addon/${name}/*/*"]
  oidc_provider_arns    = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/*"]
  tf_state_bucket_arn   = "arn:${data.aws_partition.current.partition}:s3:::${local.tf_state_bucket}"
  tf_state_object_arns = [
    for key in local.tf_state_keys :
    "${local.tf_state_bucket_arn}/${key}"
  ]
}

resource "aws_s3_bucket" "tf_state" {
  bucket = local.tf_state_bucket
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "this" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = local.trusted_principals
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_eks_small" {
  name        = local.policy_name
  description = "Permissions needed to apply the terraform-eks-small EKS stack."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EksCreateAndList"
        Effect = "Allow"
        Action = [
          "eks:CreateAddon",
          "eks:CreateCluster",
          "eks:CreateNodegroup",
          "eks:DescribeAddonVersions",
          "eks:ListAddons",
          "eks:ListClusters",
          "eks:ListUpdates",
          "eks:DescribeUpdate"
        ]
        Resource = "*"
      },
      {
        Sid    = "EksManageNamedClusterAndNodegroup"
        Effect = "Allow"
        Action = [
          "eks:DeleteAddon",
          "eks:DeleteCluster",
          "eks:DescribeAddon",
          "eks:DescribeCluster",
          "eks:DeleteNodegroup",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:TagResource",
          "eks:UntagResource",
          "eks:UpdateAddon",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion"
        ]
        Resource = concat(local.cluster_arns, local.nodegroup_arns, local.addon_arns)
      },
      {
        Sid    = "Ec2NetworkLifecycle"
        Effect = "Allow"
        Action = [
          "ec2:AllocateAddress",
          "ec2:AssociateRouteTable",
          "ec2:AttachInternetGateway",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:CreateInternetGateway",
          "ec2:CreateNatGateway",
          "ec2:CreateRoute",
          "ec2:CreateRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSubnet",
          "ec2:CreateTags",
          "ec2:CreateVpc",
          "ec2:DeleteNatGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DeleteRoute",
          "ec2:DeleteRouteTable",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteSubnet",
          "ec2:DeleteTags",
          "ec2:DeleteVpc",
          "ec2:DetachInternetGateway",
          "ec2:DisassociateRouteTable",
          "ec2:ModifySubnetAttribute",
          "ec2:ModifyVpcAttribute",
          "ec2:ReleaseAddress",
          "ec2:ReplaceRoute",
          "ec2:ReplaceRouteTableAssociation",
          "ec2:DisassociateAddress",
          "ec2:RevokeSecurityGroupEgress"
        ]
        Resource = "*"
      },
      {
        Sid    = "Ec2ReadOnlyDiscovery"
        Effect = "Allow"
        Action = [
          "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Sid    = "IamRolesForEks"
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:DetachRolePolicy",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListRolePolicies",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:UpdateAssumeRolePolicy"
        ]
        Resource = concat(local.cluster_role_arns, local.node_role_arns, local.ebs_csi_role_arns, [local.eks_nodegroup_slr_arn])
      },
      {
        Sid    = "IamManagedPolicyReadAndPassRole"
        Effect = "Allow"
        Action = [
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:PassRole"
        ]
        Resource = concat(local.managed_policy_arns, local.cluster_role_arns, local.node_role_arns, local.ebs_csi_role_arns)
      },
      {
        Sid    = "IamCreateEksServiceLinkedRole"
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = [
              "eks.amazonaws.com",
              "eks-nodegroup.amazonaws.com"
            ]
          }
        }
      },
      {
        Sid    = "IamOidcProviderCreate"
        Effect = "Allow"
        Action = [
          "iam:CreateOpenIDConnectProvider"
        ]
        Resource = "*"
      },
      {
        Sid    = "IamOidcProviderManage"
        Effect = "Allow"
        Action = [
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider"
        ]
        Resource = local.oidc_provider_arns
      },
      {
        Sid    = "Route53ManagePlaygroundZone"
        Effect = "Allow"
        Action = [
          "route53:CreateHostedZone",
          "route53:DeleteHostedZone",
          "route53:GetHostedZone",
          "route53:ListTagsForResource",
          "route53:ChangeTagsForResource",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3ListTerraformStateBucket"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = local.tf_state_bucket_arn
        Condition = {
          StringLike = {
            "s3:prefix" = local.tf_state_keys
          }
        }
      },
      {
        Sid    = "S3ManageTerraformStateObjects"
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = local.tf_state_object_arns
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.terraform_eks_small.arn
}

resource "aws_route53_zone" "playground" {
  name = "playground.swigger.io"
}

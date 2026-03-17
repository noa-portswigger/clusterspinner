provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  region           = "eu-west-2"
  role_name        = "terraform-eks-small-runner"
  policy_name      = "terraform-eks-small-runner-policy"
  eks_cluster_name = "my-cluster"
  tf_state_bucket  = "noa-tf-state-658786808637-eu-west-2-an"
  tf_state_keys = [
    "terraform-eks-small/terraform.tfstate",
    "role-with-tf-permissions/terraform.tfstate",
  ]
  trusted_principals = [
    "arn:aws:iam::658786808637:role/pipeline-roles/teleport-administrator-role"
  ]

  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]

  cluster_role_arn      = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.eks_cluster_name}-cluster-role"
  node_role_arn         = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.eks_cluster_name}-node-role"
  eks_nodegroup_slr_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"
  cluster_arn           = "arn:${data.aws_partition.current.partition}:eks:${local.region}:${data.aws_caller_identity.current.account_id}:cluster/${local.eks_cluster_name}"
  nodegroup_arn         = "arn:${data.aws_partition.current.partition}:eks:${local.region}:${data.aws_caller_identity.current.account_id}:nodegroup/${local.eks_cluster_name}/*/*"
  tf_state_bucket_arn   = "arn:${data.aws_partition.current.partition}:s3:::${local.tf_state_bucket}"
  tf_state_object_arns = [
    for key in local.tf_state_keys :
    "${local.tf_state_bucket_arn}/${key}"
  ]
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
          "eks:CreateCluster",
          "eks:CreateNodegroup",
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
          "eks:DeleteCluster",
          "eks:DescribeCluster",
          "eks:DeleteNodegroup",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:TagResource",
          "eks:UntagResource",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion"
        ]
        Resource = [
          local.cluster_arn,
          local.nodegroup_arn
        ]
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
        Resource = [
          local.cluster_role_arn,
          local.node_role_arn,
          local.eks_nodegroup_slr_arn
        ]
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
        Resource = concat(local.managed_policy_arns, [
          local.cluster_role_arn,
          local.node_role_arn
        ])
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

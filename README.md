# clusterspinner

This repository contains tools to set up an AWS Elastic Kubernetes Service cluster from scratch.
Features:

* Access your cluster from anywhere using teleport
* Manage Kubernetes configuration with ArgoCD and configuration changes committed to a git repository
* A high level of automation in the setup
* Easy to clean up and destroy all the created resources

## Architecture

There are three stages of terraform to set up the environment.

1. Create the terraform state bucket.
2. Run the account level terraform setup. This is designed to be done with a highly privileged AWS IAM Role and 
   will create a less privileged role for the next step. It will also create a Route53 DNS zone to put
   teleport endpoints in for the clusters that are created. You will need to add the NS recors for this
   zone to some other DNS zone that you already control.
3. Run the cluster level terraform setup. This can be done one or more times to set up independent clusters.

## Prerequisites

* terraform, I install my terraform with `brew install terraform`

## Installation

### Create the terraform state bucket
* Decide on a globally unique name for your bucket and an aws region to set up the bucket in.
* Set up your AWS credentials with a role with the necessary permissions to create S3 buckets.
* Go to the `terraform/create_bucket` directory and run `terraform init`,
* Run `terraform apply -var=bucket_name=$BUCKET -var=region=$REGION`

### Create the account level terraform setup
* Set up your AWS credentials with a role with braod permissions such as `AdministratorAccess`
* Go to the `terraform/with_admin_permissions` directory and run `terraform init -backend-config=bucket=$BUCKET -backend-config=region=$REGION`,
* Run `terraform apply -var=tf_state_bucket=$BUCKET -var=region=$REGION`
  * You will be prompted for cluster names that you want to create. This can be modified in the future, so if this
    is a first setup, I would recommend just picking one name. I provided `["cluster0"]` in this case.
  * You will be prompted for trusted principals. This is a list of AWS IAM principals that will be allowed to assume
    the clusterspinner role that this invocation creates.

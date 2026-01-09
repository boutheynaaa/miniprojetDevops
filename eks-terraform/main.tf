provider "aws" { 
  region = "us-east-1" 
}

# ----------------------------
# Variables
# ----------------------------
variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "lab-eks-node-group"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "Cluster"
}

# ----------------------------
# IAM Roles (LabRole)
# ----------------------------
data "aws_iam_role" "master" { 
  name = "LabRole" 
}

data "aws_iam_role" "worker" { 
  name = "LabRole" 
}

# ----------------------------
# VPC and Subnets
# ----------------------------
data "aws_vpc" "main" { 
  filter {
    name   = "tag:Name"
    values = ["Lab-VPC"] 
  }
}

data "aws_subnet" "subnet-1" { 
  vpc_id = data.aws_vpc.main.id
  filter { 
    name   = "tag:Name" 
    values = ["Public-Subnet-1"] 
  } 
}

data "aws_subnet" "subnet-2" { 
  vpc_id = data.aws_vpc.main.id
  filter { 
    name   = "tag:Name" 
    values = ["Public-Subnet-2"] 
  } 
}

data "aws_security_group" "selected" { 
  vpc_id = data.aws_vpc.main.id
  filter { 
    name   = "tag:Name" 
    values = ["Lab-SG"] 
  } 
}

# ----------------------------
# EKS Cluster
# ----------------------------
resource "aws_eks_cluster" "eks" { 
  name     = var.cluster_name
  role_arn = data.aws_iam_role.master.arn

  vpc_config { 
    subnet_ids         = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id] 
    security_group_ids = [data.aws_security_group.selected.id] 
  }

  tags = { 
    Name        = var.cluster_name
    Environment = "dev" 
    Terraform   = "true" 
  }
}

# ----------------------------
# EKS Node Group
# ----------------------------
resource "aws_eks_node_group" "node-grp" { 
  cluster_name    = aws_eks_cluster.eks.name 
  node_group_name = var.node_group_name
  node_role_arn   = data.aws_iam_role.worker.arn 
  subnet_ids      = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id] 
  capacity_type   = "ON_DEMAND" 
  disk_size       = 20 
  instance_types  = ["t2.medium"]

  scaling_config { 
    desired_size = 3 
    max_size     = 10 
    min_size     = 2 
  }

  update_config {
    max_unavailable = 1
  }

  tags = { 
    Name = var.node_group_name
  }

  # Ensure proper ordering
  depends_on = [
    aws_eks_cluster.eks
  ]
}

# ----------------------------
# OIDC Provider for ServiceAccount IAM Roles
# ----------------------------
data "tls_certificate" "oidc_thumbprint" { 
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer 
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-eks-oidc"
  }
}

# ----------------------------
# Outputs
# ----------------------------
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

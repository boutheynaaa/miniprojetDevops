# Provider
provider "aws" {
  region = "us-east-1"
}

# ----------------------------
# IAM Roles existants (LabRole)
# ----------------------------
data "aws_iam_role" "master" {
  name = "LabRole"
}

data "aws_iam_role" "worker" {
  name = "LabRole"
}

# ----------------------------
# VPC et Subnets PUBLICS
# ----------------------------
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["Lab-VPC"]
  }
}

# Utilisation des SUBNETS PUBLICS (ceux avec MapPublicIpOnLaunch = True)
data "aws_subnet" "subnet-1" {
  id = "subnet-0260180dfad65bd2d" # us-east-1a
}

data "aws_subnet" "subnet-2" {
  id = "subnet-0a38e9ba68f3e1bfb" # us-east-1b
}


data "aws_security_group" "selected" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "group-name"
    values = ["Lab-SG"]
  }
}

# ----------------------------
# EKS Cluster
# ----------------------------
resource "aws_eks_cluster" "eks" {
  name     = "MelCluster"
  role_arn = data.aws_iam_role.master.arn

  vpc_config {
    subnet_ids              = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id]
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [data.aws_security_group.selected.id]
  }

  tags = {
    Name        = "MelCluster"
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
  
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [aws_eks_cluster.eks]

  tags = {
    Name = "lab-eks-node-group"
  }
}

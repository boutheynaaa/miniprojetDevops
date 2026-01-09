# ----------------------------
# Provider
# ----------------------------
provider "aws" {
  region = "us-east-1"
}

# ----------------------------
# IAM Roles (already exist)
# ----------------------------
data "aws_iam_role" "master" {
  name = "LabRole"
}

data "aws_iam_role" "worker" {
  name = "LabRole"
}

# ----------------------------
# VPC and Public Subnets
# ----------------------------
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["Lab-VPC"]
  }
}

# Make sure these subnets are public (MapPublicIpOnLaunch = true)
data "aws_subnet" "subnet-1" { id = "subnet-0260180dfad65bd2d" } # 10.0.1.0/24 us-east-1a
data "aws_subnet" "subnet-2" { id = "subnet-05165519cc5b0da2f" } # 10.0.2.0/24 us-east-1b


# Security group in the same VPC
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
  name     = "MyCluster"
  role_arn = data.aws_iam_role.master.arn

  vpc_config {
    subnet_ids              = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id]
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [data.aws_security_group.selected.id]
  }

  tags = {
    Name        = "MyCluster"
    Environment = "dev"
    Terraform   = "true"
  }
}

# ----------------------------
# EKS Node Group
# ----------------------------
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-node-group"
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

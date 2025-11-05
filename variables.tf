variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "meowmart-cluster"
}

variable "instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.medium"
}



variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "20.0.0.0/16"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public_1.id
}

output "private_subnet_id" {
  value = aws_subnet.private_1.id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "meowmart_service_hostname" {
  value       = kubernetes_service.meowmart_service.status[0].load_balancer[0].ingress[0].hostname
  description = "Public Load Balancer DNS name for the MeowMart app"
}



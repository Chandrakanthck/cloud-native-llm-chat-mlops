output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API server endpoint"
}

output "eks_cluster_ca_certificate" {
  value       = module.eks.cluster_certificate_authority_data
  description = "EKS cluster CA certificate (base64)"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID for the cluster"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs for worker nodes"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Public subnet IDs"
}
#############################################
# Wait for EKS Control Plane to stabilize
#############################################
resource "time_sleep" "wait_for_cluster" {
  depends_on      = [module.eks]
  create_duration = "90s"
}

#############################################
# Fetch EKS Cluster connection info
#############################################
data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [time_sleep.wait_for_cluster]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [time_sleep.wait_for_cluster]
}

#############################################
# Configure Kubernetes provider with alias
#############################################
provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

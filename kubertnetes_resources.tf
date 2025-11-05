resource "kubernetes_deployment" "meowmart" {
  provider   = kubernetes.eks
  depends_on = [data.aws_eks_cluster.cluster]

  metadata {
    name = "meowmart"
    labels = {
      app = "meowmart"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "meowmart"
      }
    }

    template {
      metadata {
        labels = {
          app = "meowmart"
        }
      }

      spec {
        container {
          name  = "meowmart"
          image = "shaqdevops/meowmart-app:latest"

          port {
            container_port = 9000
          }

          resources {
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}
#########################################
# Kubernetes NLB Service with TLS
#########################################

resource "kubernetes_service" "meowmart_service" {
  provider   = kubernetes.eks
  depends_on = [kubernetes_deployment.meowmart]

  metadata {
    name = "meowmart-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"             = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = aws_acm_certificate.meowmart_cert.arn
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"        = "443"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "tcp"
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment.meowmart.metadata[0].labels.app
    }

    port {
      name        = "http"
      port        = 80
      target_port = 9000
      protocol    = "TCP"
    }

    port {
      name        = "https"
      port        = 443
      target_port = 9000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}

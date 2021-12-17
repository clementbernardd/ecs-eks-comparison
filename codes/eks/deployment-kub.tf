
# Deployment of the container
resource "kubernetes_deployment_v1" "app-staging-deployment" {
  metadata {
    name = "app2"
    labels = {
      test = "Application2"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "EKS-TP3"
      }
    }

    template {
      metadata {
        labels = {
          test = "EKS-TP3"
        }
      }

      spec {
        container {
          image = "803716525692.dkr.ecr.us-east-1.amazonaws.com/application2:latest"
          name  = "application2"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          port {
            container_port = 80
            host_port = 80
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
          }
        }
      }
    }
  }
}

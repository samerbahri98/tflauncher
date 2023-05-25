terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

variable "namespace" {
  type    = string
  default = "redis"
}

resource "kubernetes_namespace" "redis" {
  metadata {
    name = var.namespace
  }
}

resource "random_password" "redis_password" {
  length  = 24
  special = false
  keepers = {
    namespace = kubernetes_namespace.redis.id
  }
}

resource "helm_release" "redis" {
  name             = "redis"
  repository       = "https://charts.bitnami.com/bitnami"
  namespace        = var.namespace
  create_namespace = true
  chart            = "redis"
  version          = "17.10.3"

  set {
    name  = "global.redis.password"
    value = random_password.redis_password.result
  }

  set {
    name  = "replica.replicaCount"
    value = 1
  }
}

output "redis_root_pass" {
  sensitive = true
  value     = random_password.redis_password.result
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

variable "redis_password" {
  type      = string
  sensitive = true
  default   = null
}


resource "random_password" "redis_password" {
  length  = 24
  special = false
  keepers = {
    namespace = kubernetes_namespace.redis.id
  }
}


locals {
  redis_password = coalesce(var.redis_password,random_password.redis_password.result)
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

resource "helm_release" "redis" {
  name             = "redis"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  namespace        = var.namespace
  create_namespace = true
  chart            = "redis"
  version          = "17.10.3"

  set {
    name  = "global.redis.password"
    value = local.redis_password
  }

  set {
    name  = "replica.replicaCount"
    value = 1
  }
}

output "redis_root_pass" {
  sensitive = true
  value     = local.redis_password
}

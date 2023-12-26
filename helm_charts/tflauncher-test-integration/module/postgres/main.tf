terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}


variable "db_name" {
  type    = string
  default = "pgdb"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = null
}

resource "random_password" "db_password" {
  length  = 24
  special = false
  keepers = {
    db_name = var.db_name
  }
}

locals {
  db_password = coalesce(var.db_password, random_password.db_password)
}

resource "postgresql_role" "pgdb" {
  name     = var.db_name
  login    = true
  password = local.db_password
}

resource "postgresql_database" "pgdb" {
  name  = var.db_name
  owner = postgresql_role.pgdb
}

output "pgdb_pass" {
  sensitive = true
  value     = local.db_password
}

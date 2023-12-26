terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

resource "random_password" "password" {
  length  = 24
  special = false
}

output "pgdb_pass" {
  sensitive = true
  value     = random_password.password
}

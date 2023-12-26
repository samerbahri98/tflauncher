terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

variable "bucket_name" {
  type      = string
  default   = "bucket"
}

variable "file" {
  type = string #base64
  default = null
}

variable "filename" {
  type = string
  default = "file.txt"
}

resource "random_string" "file" {
  length = 24
}

locals {
  file = coalesce(var.file,random_password.random_string.file.result)
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "file" {
  bucket = aws_s3_bucket.bucket.bucket
  key = var.filename
  content_base64 = base64encode(local.file)
  etag = md5(local.file)
}

output "file_etag" {
  sensitive = true
  value = aws_s3_object.file.etag
}

output "file_metadata" {
  sensitive = true
  value = aws_s3_object.file.metadata
}

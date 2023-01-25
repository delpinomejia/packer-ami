

variable "ami-name" {
  type    = string
  default = "CentOS-Stream-ec2-8-20220919.1.x86_64-*"
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = false
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.small"
}

variable "disk_size" {
  type    = number
  default = "100"
}

variable "resource" {
  type    = string
  default = "spotfire-server"
}

variable "postgres_version" {
  type    = number
  default = "13"
}

variable "mount_dir" {
  type    = string
  default = "mnt/spotfire"
}

variable "hostname" {
  type    = string
  default = "spotfire-server"
}

variable "s3_bucket" {
  type    = string
  default = "test-spotfire"
}
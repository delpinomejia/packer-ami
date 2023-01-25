packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

# variable "region" {
#   type    = string
# }

data "amazon-ami" "centos" {
  access_key = "${var.aws_access_key}"
  filters = {
    name                = "${var.ami-name}"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["aws-marketplace"]
  region      = "${var.region}"
  secret_key  = "${var.aws_secret_key}"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


source "amazon-ebs" "centos" {
  access_key    = "${var.aws_access_key}"
  ami_name      = "Base-CentOS-${local.timestamp}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  secret_key    = "${var.aws_secret_key}"
  source_ami    = "${data.amazon-ami.centos.id}"
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "30"
    volume_type           = "gp2"
    delete_on_termination = true
  }
  launch_block_device_mappings {
    device_name           = "/dev/sdb"
    volume_size           = "${var.disk_size}"
    volume_type           = "gp2"
    delete_on_termination = false
  }

  ssh_username = "centos"
  tags = {
    Name = "Base-CentOS-${var.resource}"
  }

}

build {
  sources = ["source.amazon-ebs.centos"]

  provisioner "shell" {
    inline = ["sleep 30", "sudo yum -y update", "sudo yum install -y postgresql unzip wget curl ca-certificates xfsprogs", "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip", "unzip awscliv2.zip", "sudo ./aws/install", "dnf module list postgresql", "sudo dnf module reset postgresql -y", "sudo dnf module enable postgresql:${var.postgres_version} -y", "sudo dnf install postgresql-server"]
  }

  provisioner "shell" {
    inline = ["sudo fdisk -l", "sudo file -s /dev/xvdb", "sudo mkfs -t ext4 /dev/xvdb", "sudo mkdir ${var.mount_dir}", "sudo mount /dev/xvdb ${var.mount_dir}", "sudo df -h", "sudo hostnamectl set-hostname ${var.hostname}", "/usr/local/bin/aws s3 cp s3://${var.s3_bucket} . --recursive"]
  }

}


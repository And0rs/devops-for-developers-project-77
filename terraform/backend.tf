terraform {
  backend "s3" {
    bucket   = "tfstate-devops3"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

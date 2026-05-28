variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth or IAM token"
  sensitive   = true
}

variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
}

variable "zone" {
  type        = string
  description = "Yandex Cloud default availability zone"
  default     = "ru-central1-a"
}

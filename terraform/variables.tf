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

variable "domain" {
  type        = string
  description = "Domain name for the application"
  default     = "percacaosu.online"
}

variable "datadog_api_key" {
  type        = string
  description = "Datadog API key"
  sensitive   = true
}

variable "datadog_app_key" {
  type        = string
  description = "Datadog Application key"
  sensitive   = true
}

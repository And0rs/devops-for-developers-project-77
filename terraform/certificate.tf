resource "yandex_cm_certificate" "le_cert" {
  name        = "devops-letsencrypt"
  description = "Let's Encrypt certificate for ALB public IP"

  self_managed {
    certificate = file("../certs/fullchain.pem")
    private_key = file("../certs/privkey.pem")
  }
}

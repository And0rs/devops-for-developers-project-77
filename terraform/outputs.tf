output "vm-1-public-ip" {
  value = yandex_compute_instance.vm-1.network_interface[0].nat_ip_address
}

output "vm-2-public-ip" {
  value = yandex_compute_instance.vm-2.network_interface[0].nat_ip_address
}

output "alb-public-ip" {
  value = yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "lb-url" {
  value = "http://${yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}"
}

output "lb-url-https" {
  value = "https://${yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}"
}

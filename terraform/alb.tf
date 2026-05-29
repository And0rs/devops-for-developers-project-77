resource "yandex_alb_target_group" "tg" {
  name = "devops-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.subnet.id
    ip_address = yandex_compute_instance.vm-1.network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet.id
    ip_address = yandex_compute_instance.vm-2.network_interface[0].ip_address
  }
}

resource "yandex_alb_backend_group" "backend_group" {
  name = "devops-backend-group"

  http_backend {
    name             = "nginx-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.tg.id]

    healthcheck {
      timeout  = "2s"
      interval = "2s"

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "router" {
  name = "devops-http-router"
}

resource "yandex_alb_virtual_host" "vh" {
  name           = "devops-vh"
  http_router_id = yandex_alb_http_router.router.id
  authority      = [var.domain]

  route {
    name = "nginx-route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend_group.id
        timeout          = "30s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name = "devops-alb"

  network_id = yandex_vpc_network.network.id

  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = yandex_vpc_subnet.subnet.id
    }
  }

  listener {
    name = "http-listener"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }

  listener {
    name = "https-listener"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [443]
    }

    tls {
      default_handler {
        http_handler {
          http_router_id = yandex_alb_http_router.router.id
        }
        certificate_ids = [yandex_cm_certificate.le_cert.id]
      }
    }
  }

}

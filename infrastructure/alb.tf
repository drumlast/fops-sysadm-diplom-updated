resource "yandex_alb_target_group" "web_tg" {
  name = "web-target-group"
  dynamic "target" {
    for_each = yandex_compute_instance.web[*]
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web_bg" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_tg.id]

    healthcheck {
      interval = "10s"
      timeout  = "5s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "http_router" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "vh" {
  name           = "web-vh"
  http_router_id = yandex_alb_http_router.http_router.id
  route {
    name = "web-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_bg.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name       = "web-alb"
  network_id = yandex_vpc_network.main.id
  security_group_ids = [yandex_vpc_security_group.web.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
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
        http_router_id = yandex_alb_http_router.http_router.id
      }
    }
  }
}
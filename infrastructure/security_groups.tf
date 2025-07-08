resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-sg"
  network_id = yandex_vpc_network.main.id

  # Входящий трафик от well-known ranges Яндекса для health checks
  ingress {
    protocol       = "TCP"
    description    = "Allow health checks from Yandex"
    port           = 80
    v4_cidr_blocks = [
      "130.193.0.0/16",
      "178.154.0.0/16"
    ]
  }

  # Исходящий трафик к backend-серверам (web-серверы)
  egress {
    protocol       = "TCP"
    description    = "Send traffic to backend web instances"
    port           = 80
    v4_cidr_blocks = ["10.10.2.0/24"]
  }
}
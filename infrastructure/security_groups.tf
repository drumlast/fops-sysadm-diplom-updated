resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.main.id

    ingress {
    protocol       = "TCP"
    description    = "Allow SSH from anywhere"
    port           = 22
    v4_cidr_blocks = ["46.228.7.154/32"]
  }

   egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "yandex_vpc_security_group" "nat" {
  name       = "nat-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "ANY"
    description    = "Allow all from private subnet"
    v4_cidr_blocks = ["10.10.2.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow ICMP from private subnet"
    v4_cidr_blocks = ["10.10.2.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from my IP"
    v4_cidr_blocks = ["46.228.7.154/32"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "web-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from bastion or your IP"
    v4_cidr_blocks = ["10.10.1.0/24", "46.228.7.154/32"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow ICMP from NAT"
    v4_cidr_blocks = ["10.10.1.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
  protocol       = "TCP"
  description    = "Allow HTTP from ALB and bastion"
  port           = 80
  v4_cidr_blocks = ["10.10.1.0/24", "10.10.2.0/24", "IP-ALB", "IP-BASTION"]
}
}
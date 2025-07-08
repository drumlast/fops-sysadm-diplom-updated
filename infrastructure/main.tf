terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.87"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "main" {
  name = "main-vpc"
}
resource "yandex_vpc_gateway" "internet" {
  name = "internet-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "public" {
  network_id = yandex_vpc_network.main.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id        = yandex_vpc_gateway.internet.id
  }
}

resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.1.0/24"]
  route_table_id = yandex_vpc_route_table.public.id
}

resource "yandex_vpc_subnet" "private" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.2.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}
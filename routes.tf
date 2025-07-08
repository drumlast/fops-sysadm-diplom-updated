resource "yandex_vpc_route_table" "private" {
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "10.10.1.6"
  }
}
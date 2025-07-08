resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd876gids9srs8ma0592"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "null_resource" "nat_setup" {
  depends_on = [yandex_compute_instance.nat]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.nat.network_interface.0.nat_ip_address
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      # Включаем IP forwarding
      "sudo sysctl -w net.ipv4.ip_forward=1",
      "sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf",
      # NAT через iptables
      "sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
      # --- Важно: предотвращаем зависание установки iptables-persistent ---
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo DEBIAN_FRONTEND=noninteractive apt update",
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent",
      "sudo netfilter-persistent save"
    ]
  }
}
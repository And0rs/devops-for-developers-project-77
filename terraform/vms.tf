resource "yandex_vpc_network" "network" {
  name = "devops-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "devops-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = data.yandex_compute_image.os_image.id
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = data.yandex_compute_image.os_image.id
}

resource "yandex_compute_instance" "vm-1" {
  name        = "app-01"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("../key/yc.pub")}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - docker.io
      runcmd:
        - [systemctl, enable, docker]
        - [systemctl, start, docker]
        - docker run -d --name nginx -p 80:80 nginx:alpine
    EOF
  }

  depends_on = [yandex_compute_disk.boot-disk-1]
}

resource "yandex_compute_instance" "vm-2" {
  name        = "app-02"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("../key/yc.pub")}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - docker.io
      runcmd:
        - [systemctl, enable, docker]
        - [systemctl, start, docker]
        - docker run -d --name nginx -p 80:80 nginx:alpine
    EOF
  }

  depends_on = [yandex_compute_disk.boot-disk-2]
}

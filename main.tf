variable crendential_file_path {}
variable private_key_path {}
variable username {}
variable project_id {}

provider "google" {
  credentials = file(var.crendential_file_path)
  project = var.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20200414"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.username}:${file(var.private_key_path)}"
  }
}

resource "google_compute_firewall" "default" {
 name    = "web-firewall"
 network = "default"

 allow {
   protocol = "icmp"
 }

 allow {
   protocol = "tcp"
   ports    = ["8080"]
 }

 allow {
   protocol = "tcp"
   ports    = ["22"]
 }

 source_ranges = ["0.0.0.0/0"]
 target_tags = ["web"]
}

output "ip-address" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
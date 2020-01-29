provider "google" {
    credentials = "${file("service-account.json")}"
    project = "${var.project_id}"    
}

resource "google_compute_network" "vpc-1" {
    name = "${format("%s","${var.company}-${var.env}-network")}"
    auto_create_subnetworks = "false"
    routing_mode = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet-ae" {

    name = "${format("%s","${var.company}-${var.env}-east-subnet")}"
    network = "${google_compute_network.vpc-1.self_link}"
    region = "asia-east1"
    ip_cidr_range = "${var.ae_private_subnet}"

}

resource "google_compute_subnetwork" "subnet-as" {

    name = "${format("%s","${var.company}-${var.env}-south-subnet")}"
    network = "${google_compute_network.vpc-1.self_link}"
    region = "asia-south1"
    ip_cidr_range = "${var.as_private_subnet}"

}

resource "google_compute_firewall" "fw-internal" {

    name = "${format("%s","${var.company}-${var.env}-internal-fw")}"
    network = "${google_compute_network.vpc-1.self_link}"
    
    allow {
        protocol = "icmp"
    }
    
    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = [
        "${var.ae_private_subnet}", 
        "${var.as_private_subnet}"
    ]
 
}

resource "google_compute_firewall" "fw-ssh" {

    name = "${format("%s","${var.company}-${var.env}-ssh")}"
    network = "${google_compute_network.vpc-1.self_link}"
    

    allow {
        protocol = "tcp"
        ports = ["22"]
    }
y
    target_tags = ["bastion"]
    source_ranges = ["0.0.0.0/0"]
 
}

resource "google_compute_firewall" "fw-http" {

    name = "${format("%s","${var.company}-${var.env}-http-ssh")}"
    network = "${google_compute_network.vpc-1.self_link}"
    

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    target_tags = ["http"]
 
}
data "google_compute_image" "debian" {
    family = "ubuntu-1804-lts"
    project = "gce-uefi-images"
}

resource "google_compute_instance" "bastion" {

    name = "${format("%s","${var.company}-${var.env}-host")}"
    machine_type = "n1-standard-1"
    zone = "asia-east1-a"
    tags = ["bastion"]
    boot_disk {
        initialize_params {
            image = "${data.google_compute_image.debian.self_link}"
        }
    }

    network_interface {
        network = "${google_compute_network.vpc-1.self_link}"
        subnetwork = "${google_compute_subnetwork.subnet-ae.self_link}"
        access_config {
            // Ephemeral IP
        }
    }
  
}

resource "google_compute_instance" "webserver" {

    name = "${format("%s","${var.company}-${var.env}-nginx")}"
    machine_type = "n1-standard-1"
    zone = "asia-south1-a"
    tags = ["http"]
    boot_disk {
        initialize_params {
            image = "${data.google_compute_image.debian.self_link}"
        }
    }

    network_interface {
        network = "${google_compute_network.vpc-1.self_link}"
        subnetwork = "${google_compute_subnetwork.subnet-as.self_link}"
        access_config {
            // Ephemeral IP
        }
    }
    
    metadata_startup_script = "${data.template_file.nginx.rendered}"   
}

data "template_file" "nginx"{
    template = "${file("nginx-script.tpl")}"

    vars = {
        ufw_allow_nginx = "Nginx HTTP"
    }
}


provider "google" {

  project     = "${var.project_id}"
  credentials = "${file("service-account.json")}"

}

provider "google-beta" {
  credentials = file("/home/david/private-keys/credential-terraform-dataproc-gke.json")
  project     = "${var.project_dataproc_gke}"
  region      = "${var.region}"
}

resource "google_container_cluster" "cluster-dataproc-gke" {
  project                  = "${var.project_dataproc_gke}"
  name                     = "${var.name_cluster_dataproc_gke}"
  location                 = "${var.region}"
  remove_default_node_pool = true
  initial_node_count       = 1



  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

}

resource "google_container_node_pool" "cluster-dataproc-gke-node-pool" {
  project    = "${var.project_dataproc_gke}"
  name       = "${var.name_cluster_dataproc_gke}-node-pool"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.cluster-dataproc-gke.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "${var.machine_type}"
    disk_size_gb = 75
    disk_type    = "${var.disk_type}"
    image_type   = "${var.image_type}"


    metadata = {
      disable-legacy-endpoints = "true"
    }



    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}


resource "google_dataproc_cluster" "cluster-dataproc" {
  provider = "google-beta"
  name     = "${var.name_cluster_dataproc}"
  region   = "${var.region}"


  cluster_config {
    staging_bucket = "${var.staging_bucket_dataproc}"



    # Override or set some custom properties
    software_config {
      image_version = "1.4.27-beta"
    }


  }
}
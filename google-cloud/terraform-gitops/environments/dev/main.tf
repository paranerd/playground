provider "google" {
  project = "${var.project_id}"
}

resource "google_project_service" "cloud_run" {
  project = var.project_id
  service = "run.googleapis.com"
}

#data "google_iam_policy" "noauth" {
#  binding {
#    role = "roles/run.invoker"
#    members = [
#      "allUsers",
#    ]
#  }
#}

resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = "us-central1"
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  depends_on = [
    google_project_service.cloud_run
  ]
}

#resource "google_cloud_run_service_iam_policy" "noauth" {
#  location    = google_cloud_run_v2_service.default.location
#  project     = google_cloud_run_v2_service.default.project
#  service     = google_cloud_run_v2_service.default.name

#  policy_data = data.google_iam_policy.noauth.policy_data
#}
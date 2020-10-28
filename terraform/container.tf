resource "google_container_registry" "increment_integer_svc" {
  location = "US"
}

resource "google_cloud_run_service" "increment_integer_svc" {
  name     = "increment-integer-svc"
  location = var.region_id
  autogenerate_revision_name = true    

  template {
    spec {
      containers {
        image = "gcr.io/path_to_your_container.run.app"
        ports {
          container_port = 9292
        }
        env {
          name = "DB_HOST"
          value = "/cloudsql/${var.project_id}:${var.region_id}:${google_sql_database_instance.increment_integer_svc.name}"
        }
        env {
          name = "DB_NAME"
          value = google_sql_database.increment_integer_svc.name
        }
        env {
          name = "DB_USERNAME"
          value = google_sql_user.increment_integer_svc_root.name
        }
        env {
          name = "DB_PASSWORD"
          value = google_sql_user.increment_integer_svc_root.password
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = "${var.project_id}:${var.region_id}:${google_sql_database_instance.increment_integer_svc.name}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_policy" "increment_integer_svc" {
  location    = google_cloud_run_service.increment_integer_svc.location
  project     = google_cloud_run_service.increment_integer_svc.project
  service     = google_cloud_run_service.increment_integer_svc.name
  policy_data = data.google_iam_policy.all_users_run_invoker.policy_data
}
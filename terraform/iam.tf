data "google_iam_policy" "all_users_run_invoker" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

data "google_iam_policy" "all_users_storage_object_viewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "allUsers",
    ]
  }
}

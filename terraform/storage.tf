resource "google_storage_bucket" "increment_integer_www_artifacts" {
  name          = "increment-integer-www-artifacts"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "increment_integer_www" {
  name          = "increment-integer-www"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_policy" "increment_integer_www" {
  bucket    = google_storage_bucket.increment_integer_www.name
  policy_data = data.google_iam_policy.all_users_storage_object_viewer.policy_data
}

  
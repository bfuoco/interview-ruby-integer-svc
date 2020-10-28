resource "google_sql_database_instance" "increment_integer_svc" {
  name                = "increment-integer-svc"
  region              = var.region_id
  database_version    = "POSTGRES_12"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "increment_integer_svc" {
  name     = "main"
  instance = google_sql_database_instance.increment_integer_svc.name
}

resource "google_sql_user" "increment_integer_svc_root" {
  name     = "postgres"
  instance = google_sql_database_instance.increment_integer_svc.name
  password = "password1"
}
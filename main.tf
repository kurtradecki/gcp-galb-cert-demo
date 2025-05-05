/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# create global static external IP address used to reach the load balancer
resource "google_compute_global_address" "lb_static_ip" {
  project = var.project_name_and_id
  name         = "${var.lb_static_ip_name_prefix}-${var.url_map_name}${var.iteration}"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# enable certificatemanager api
resource "google_project_service" "certificatemanager_api" {
  project = var.project_name_and_id
  service = "certificatemanager.googleapis.com"
}

# create certificate
resource "google_compute_managed_ssl_certificate" "cert" {
  project = var.project_name_and_id
  name = "${var.cert_name_prefix}-${var.url_map_name}${var.iteration}"
  managed {
    domains = ["${google_compute_global_address.lb_static_ip.address}.nip.io"]
  }
}


# create Cloud Armor policy for only allowed IPs
resource "google_compute_security_policy" "cloudarmor_policy" {
  count = var.enable_cloud_armor ? 1 : 0
  project = var.project_name_and_id
  name = "${var.cloudarmor_policy_name_prefix}-${var.url_map_name}"
  rule {
    action   = "allow"
    priority = "10000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.cloud_armor_allowed_ips
      }
    }
    description = "Trusted IPs"
  }
  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}

### create Load balancer with backend … multiple resources

resource "google_cloud_run_service" "cloudrun_svc" {
  project  = var.project_name_and_id
  name     = "${var.cloudrun_svc_name_prefix}-${var.url_map_name}${var.iteration}"
  location = var.gcp_region
  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"   # ingress setting
    }
  }
  template {
    spec {
      containers {
         image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.cloudrun_svc.location
  project     = var.project_name_and_id
  service     = google_cloud_run_service.cloudrun_svc.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  project               = var.project_name_and_id
  name                  = "${var.cloudrun_neg_name_prefix}-${var.url_map_name}${var.iteration}"
  network_endpoint_type = "SERVERLESS"
  region                = var.gcp_region
  cloud_run {
    service = google_cloud_run_service.cloudrun_svc.name
  }
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "backend_service" {
  project                 = var.project_name_and_id
  name                    = "${var.backend_service_name_prefix}-${var.url_map_name}${var.iteration}"
  load_balancing_scheme   = "EXTERNAL_MANAGED"
  security_policy         = var.enable_cloud_armor ? google_compute_security_policy.cloudarmor_policy[0].id : ""
  backend {
    group           = google_compute_region_network_endpoint_group.cloudrun_neg.self_link
    balancing_mode = "UTILIZATION" 
  }
}

# url map
resource "google_compute_url_map" "url_map" {
  project         = var.project_name_and_id
  name            = "${var.url_map_name}${var.iteration}"
  default_service = google_compute_backend_service.backend_service.id
}

# https proxy
resource "google_compute_target_https_proxy" "proxy_https" {
  project = var.project_name_and_id
  name     = "${var.proxy_http_name_prefix}s-${var.url_map_name}${var.iteration}"
  url_map  = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.cert.id]
}

# forwarding rule for https
resource "google_compute_global_forwarding_rule" "forwarding_rule_https" {
  project               = var.project_name_and_id
  name                  = "${var.forwarding_rule_name_prefix}-https-${var.url_map_name}${var.iteration}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
#  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.proxy_https.id
  ip_address            = google_compute_global_address.lb_static_ip.id
}

# http proxy
resource "google_compute_target_http_proxy" "proxy_http" {
  count    = var.enable_http ? 1 : 0
  project  = var.project_name_and_id
  name     = "${var.proxy_http_name_prefix}-${var.url_map_name}${var.iteration}"
  url_map  = google_compute_url_map.url_map.id
}

# forwarding rule for http
resource "google_compute_global_forwarding_rule" "forwarding_rule_http" {
  count                 = var.enable_http ? 1 : 0
  project               = var.project_name_and_id
  name                  = "${var.forwarding_rule_name_prefix}-http-${var.url_map_name}${var.iteration}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.proxy_http[0].id
  ip_address            = google_compute_global_address.lb_static_ip.id
}

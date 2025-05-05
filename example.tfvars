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

# This top section meant to be changed to fit your environment
  project_id = "<ENTER PROJECT ID HERE>"
  gcp_region = "<ENTER REGION HERE>"
  iteration = "<ENTER AN ITERATION HERE, EG 1>"
  name_base = "<ENTER A NAME HERE, EG MYORG-NAME>"
  cloud_armor_allowed_ips = ["<ENTER AN IP HERE, EG 1.2.3.4/32"]  # add IPs that need access to load balancers, only relevant if enable_cloud_armor below is true

# If needed, set values optional components
  enable_http = true  # true to create HTTP & HTTPS frontends, false to create only HTTPS frontend
  enable_cloud_armor = true  # true to add IP filtering via Cloud Armor, false if not needed

# No need to change anything below this line unless you want to change resource naming
  cloudrun_neg_name_prefix = "srvrlessneg-cloudrun"
  cloudrun_svc_name_prefix = "cloudrun-example"
  url_map_name = "lb-ga"  # becomes the load balancer name for an application load balancer
  cert_name_prefix = "cert"
  lb_static_ip_name_prefix = "static-ip"
  cloudarmor_policy_name_prefix = "cldarmr-pol"
  forwarding_rule_name_prefix = "fr"
  proxy_http_name_prefix = "proxy-http"
  backend_service_name_prefix = "be"

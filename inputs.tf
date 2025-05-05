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

variable project_id {
  type = string
}

/*
variable "billing_account" {
  description = "Billing account id."
  type        = string
  default     = null
}

variable "project_parent" {
  description = "Parent folder or organization in 'folders/folder_id' or 'organizations/org_id' format."
  type        = string
  default     = null
  validation {
    condition     = var.project_parent == null || can(regex("(organizations|folders)/[0-9]+", var.project_parent)
)
    error_message = "Parent must be of the form folders/folder_id or organizations/organization_id."
  }
}
*/

# enforced / not enforced type policies
variable boolorgpols {
  description = "APIs to enable"
  type        = list(string)
}

# allow all / deny all type org policies
variable listorgpols {
  description = "APIs to enable"
  type        = list(string)
}

variable gcp_region {
  type = string    
}

variable url_map_name {
  type = string    
}

variable cert_name_prefix {
  type = string
}

variable lb_static_ip_name_prefix {
  type = string    
}

variable cloudarmor_policy_name_prefix{
  type = string
}

variable forwarding_rule_name_prefix {
  type = string    
}

variable proxy_http_name_prefix {
  type = string   
}

variable backend_service_name_prefix {
  type = string
}

variable name_base {
  type = string
}

variable cloudrun_neg_name_prefix {
  type = string
}

variable cloudrun_svc_name_prefix {
  type = string
}

variable iteration {
  type = string
}

variable enable_http {
  type = bool
}

variable enable_cloud_armor {
  type = bool
}

variable cloud_armor_allowed_ips {
  type = list(string)
}

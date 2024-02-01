# Copyright (C) 2020 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

data "google_storage_project_service_account" "gcs_account" {
  project = var.project
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "2.3.0"

  count = var.enable_kms ? 1 : 0

  project_id     = var.project
  location       = var.keyring_location
  keyring        = local.service
  keys           = var.keys
  set_owners_for = var.keys
  owners         = var.owners

  encrypters = [
    data.google_storage_project_service_account.gcs_account.email_address
  ]
  decrypters = [
    data.google_storage_project_service_account.gcs_account.email_address
  ]

  labels = var.kms_labels
}

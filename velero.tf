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

# Doc: https://github.com/vmware-tanzu/velero-plugin-for-gcp#setup

module "service_account" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "4.0.3"

  project_id = var.project

  names = [
    local.service
  ]
}

module "custom" {
  source  = "terraform-google-modules/iam/google//modules/custom_role_iam"
  version = "7.3.0"

  target_level = "project"
  target_id    = var.project
  role_id      = local.service
  title        = local.service
  description  = format("Role for %s", local.service)
  base_roles   = []

  permissions = [
    "compute.disks.get",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.snapshots.get",
    "compute.snapshots.create",
    "compute.snapshots.useReadOnly",
    "compute.snapshots.delete",
    "compute.zones.get"
  ]

  excluded_permissions = []

  members = []
  # members = [
  #   format("serviceAccount:%s", module.service_account.email),
  # ]
}

module "iam" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version = "7.3.0"

  project = var.project

  service_accounts = [
    module.service_account.email
  ]
  mode = "authoritative"

  bindings = {
    "roles/velero" = [
      format("serviceAccount:%s", module.service_account.email),
    ]
    "roles/iam.workloadIdentityUser" = [
      format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, var.namespace, var.service_account)
    ]
  }

  # depends_on = [module.service_account]
}

module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "3.0.0"

  name            = format("%s-%s", var.project, local.service)
  project_id      = var.project
  location        = var.bucket_location
  storage_class   = var.bucket_storage_class
  labels          = var.bucket_labels
  lifecycle_rules = var.lifecycle_rules

  encryption = var.enable_kms ? {
    default_kms_key_name = google_kms_crypto_key.velero[0].name
  } : null

  iam_members = [{
    role   = "roles/storage.objectAdmin"
    member = format("serviceAccount:%s", module.service_account.email)
  }]

  # depends_on = [module.service_account]
}

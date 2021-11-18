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

module "custom_role" {
  source  = "terraform-google-modules/iam/google//modules/custom_role_iam"
  version = "7.3.0"

  target_level = "project"
  target_id    = var.project
  role_id      = local.service
  title        = title(local.service)
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

  members = [
    # https://github.com/terraform-google-modules/terraform-google-cloud-storage/issues/142
    # format("serviceAccount:%s", module.service_account.email),
    format("%s@%s.iam.gserviceaccount.com", local.service, var.project),
  ]

  depends_on = [
    module.service_account
  ]
}

module "iam_service_accounts" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version = "7.3.0"

  project = var.project
  mode    = "authoritative"

  service_accounts = [
    # https://github.com/terraform-google-modules/terraform-google-cloud-storage/issues/142
    # module.service_account.email
    format("%s@%s.iam.gserviceaccount.com", local.service, var.project),
  ]

  bindings = {
    "roles/iam.workloadIdentityUser" = [
      format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, var.namespace, var.service_account)
    ]
  }

  depends_on = [
    module.service_account
  ]
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

  # https://github.com/terraform-google-modules/terraform-google-cloud-storage/issues/142
  # iam_members = [{
  #   role   = "roles/storage.objectAdmin"
  #   member = format("serviceAccount:%s", module.service_account.email)
  # }]
}

module "iam_storage_buckets" {
  source  = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version = "7.3.0"

  storage_buckets = [module.bucket.bucket.name]
  mode            = "authoritative"

  bindings = {
    "roles/storage.objectAdmin" = [
      # https://github.com/terraform-google-modules/terraform-google-cloud-storage/issues/142
      format("serviceAccount:%s@%s.iam.gserviceaccount.com", local.service, var.project),
    ]
  }

  depends_on = [
    module.service_account
  ]
}

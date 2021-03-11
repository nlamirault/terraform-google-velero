# Velero into Google Cloud Platform

![Tfsec](https://github.com/nlamirault/terraform-google-velero/workflows/Tfsec/badge.svg)

## Usage

```hcl
module "velero" {
  source  = "nlamirault/velero/google"
  version = "1.0.0"

  project = var.project

  bucket_location      = var.bucket_location
  bucket_storage_class = var.bucket_storage_class
  bucket_labels        = var.bucket_labels

  namespace       = var.namespace
  service_account = var.service_account

  keyring_location = var.keyring_location
}
```

and variables :

```hcl
project = "foo-prod"

region = "europe-west1"

##############################################################################
# Velero

bucket_location      = "europe-west1"
bucket_storage_class = "STANDARD"
bucket_labels        = {
  env      = "prod"
  service  = "velero"
  made-by  = "terraform"
}

namespace       = "storage"
service_account = "velero"

keyring_location = "europe-west1"
```

## Documentation

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

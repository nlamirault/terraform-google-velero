# Velero into Google Cloud Platform

![Tfsec](https://github.com/nlamirault/terraform-google-velero/workflows/Tfsec/badge.svg)

## Terraform versions

Use Terraform `>= 0.14.0` minimum and Terraform Provider Google `3.54+`.

These types of resources are supported:

* [google_service_account](https://www.terraform.io/docs/providers/google/r/google_service_account.html)
* [google_kms_key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring)
* [google_kms_crypto_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key)
* [google_kms_crypto_key_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_kms_crypto_key_iam)
* [google_storage_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)
* [google_project_iam_custom_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam_custom_role)
* [google_project_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam)
* [google_storage_bucket_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_member)
* [google_service_account_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_member)

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

### Providers

| Name | Version |
|------|---------|
| google | 3.54.0 |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| bucket\_labels | Map of labels to apply to the bucket | `map(string)` | <pre>{<br>  "made-by": "terraform"<br>}</pre> | no |
| bucket\_location | The bucket location | `string` | n/a | yes |
| bucket\_storage\_class | Bucket storage class. | `string` | `"MULTI_REGIONAL"` | no |
| keyring\_location | The KMS keyring location | `string` | n/a | yes |
| namespace | The Kubernetes namespace | `string` | n/a | yes |
| project | The project in which the resource belongs | `string` | n/a | yes |
| service\_account | The Kubernetes service account | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| service\_account | Service Account for Velero |

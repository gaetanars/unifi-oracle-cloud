# Bootstrap script to create OCI Object Storage bucket for Terraform state
# Run this ONCE before configuring the backend
#
# Usage:
#   cd terraform/backend-setup
#   terraform init
#   terraform apply

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Get namespace
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.tenancy_ocid
}

# Create bucket for Terraform state
resource "oci_objectstorage_bucket" "terraform_state" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = var.bucket_name
  access_type    = "NoPublicAccess"

  # Enable versioning for state history
  # This keeps all versions of terraform.tfstate
  versioning = "Enabled"

  # Note: Cannot use retention_rules when versioning is enabled
  # Versioning already provides history - old versions can be deleted manually if needed

  freeform_tags = {
    Project     = "UniFi-Network"
    Purpose     = "Terraform-State"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Output instructions
output "namespace" {
  description = "Object Storage namespace"
  value       = data.oci_objectstorage_namespace.ns.namespace
}

output "bucket_name" {
  description = "Bucket name for Terraform state"
  value       = oci_objectstorage_bucket.terraform_state.name
}

output "region" {
  description = "OCI region"
  value       = var.region
}



output "next_steps" {
  description = "Next steps to configure backend"
  value       = <<-EOT

  ✅ Bucket created successfully with versioning and state locking enabled!

  📝 Next steps:

  1. Configure backend in ../backend.tf:
     - Copy: cp ../backend.tf.example ../backend.tf
     - Edit ../backend.tf and replace these 2 values:
       * bucket:    ${oci_objectstorage_bucket.terraform_state.name}
       * namespace: ${data.oci_objectstorage_namespace.ns.namespace}
       * region:    ${var.region}

  2. Verify credentials in .env:
     - Backend uses existing OCI credentials (TF_VAR_*)
     - No additional credentials needed!

  3. Migrate existing state (if any):
     cd ..
     terraform init -migrate-state

  ℹ️  Features:
      - Versioning: All tfstate versions are kept automatically
      - State locking: Automatic (prevents concurrent modifications)
      - Uses native OCI backend (not S3-compatible)

  EOT
}

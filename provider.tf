terraform {

  # Required Terraform version
  required_version = ">= 1.4.0"

  # Required OCI Terraform Provider version
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.0"
    }

    oci = {
      source  = "oracle/oci"
      version = ">= 6.2.0"
    }
  }

  # Use OCI Object Storage as backend for storing Terraform state files
  #backend "http" {
  #    address = "https://objectstorage.eu-frankfurt-1.oraclecloud.com/<my-access-uri>" update_method = "PUT"
  #}
}

locals {
  use_oci_config_file_profile = (var.oci_config_file_profile != null && var.oci_config_file_profile != "")
}

# Configure the Oracle Cloud Infrastructure provider
provider "oci" {
  config_file_profile = local.use_oci_config_file_profile ? var.oci_config_file_profile : null

  tenancy_ocid     = local.use_oci_config_file_profile ? null : var.tenancy_ocid
  user_ocid        = local.use_oci_config_file_profile ? null : var.current_user_ocid
  fingerprint      = local.use_oci_config_file_profile ? null : var.oci_api_key_fingerprint
  private_key_path = local.use_oci_config_file_profile ? null : var.oci_api_private_key_path
  region           = local.use_oci_config_file_profile ? null : var.region
}

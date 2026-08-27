locals {

  jmeter_resources_bucket_name           = (var.jmeter_binaries_object_storage_upload_required ? oci_objectstorage_bucket.jmeter_resources[0].name : var.jmeter_resources_bucket_name)
  jmeter_resources_bucket_compartment_id = (var.jmeter_resources_bucket_compartment_id != null ? var.jmeter_resources_bucket_compartment_id : var.nodes_compartment_id)

  jmeter_resources_par_url = (var.jmeter_binaries_object_storage_upload_required ? trimsuffix(oci_objectstorage_preauthrequest.jmeter_resources[0].full_path, "/") : trimsuffix(var.jmeter_resources_par_url, "/"))

  jmeter_binaries_archive_name = "apache-jmeter-${var.jmeter_version}.tgz"
  jmeter_binaries_object_name  = "binaries/${local.jmeter_binaries_archive_name}"

  jmeter_binaries_download_required        = (var.jmeter_binaries_object_storage_upload_required && var.jmeter_binaries_local_path == null)
  jmeter_binaries_download_local_directory = (var.jmeter_binaries_download_directory != null ? var.jmeter_binaries_download_directory : "${path.module}/.downloads")
  jmeter_binaries_download_local_path      = "${local.jmeter_binaries_download_local_directory}/${local.jmeter_binaries_archive_name}"

  jmeter_binaries_download_url = "${var.jmeter_binaries_base_url}/${local.jmeter_binaries_archive_name}"
  jmeter_binaries_local_path   = (local.jmeter_binaries_download_required ? data.external.download_jmeter_binaries[0].result.path : var.jmeter_binaries_local_path)

  jmeter_binaries_effective_url = (var.jmeter_binaries_object_storage_upload_required ? "${trimsuffix(local.jmeter_resources_par_url, "/")}/binaries" : trimsuffix(var.jmeter_binaries_base_url, "/"))
}

data "external" "download_jmeter_binaries" {
  count = (local.jmeter_binaries_download_required ? 1 : 0)

  program = [
    "${path.module}/scripts/download-jmeter-binaries",
    local.jmeter_binaries_download_url,
    local.jmeter_binaries_download_local_path
  ]
}

resource "oci_objectstorage_bucket" "jmeter_resources" {
  count = (var.jmeter_binaries_object_storage_upload_required ? 1 : 0)

  compartment_id = local.jmeter_resources_bucket_compartment_id
  namespace      = data.oci_objectstorage_namespace.object_storage_namespace.namespace
  name           = var.jmeter_resources_bucket_name
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
}

resource "oci_objectstorage_object" "jmeter_binaries" {
  count = (var.jmeter_binaries_object_storage_upload_required ? 1 : 0)

  namespace    = data.oci_objectstorage_namespace.object_storage_namespace.namespace
  bucket       = local.jmeter_resources_bucket_name
  object       = local.jmeter_binaries_object_name
  source       = local.jmeter_binaries_local_path
  content_type = var.jmeter_resources_object_content_type
  storage_tier = "InfrequentAccess"

  lifecycle {
    precondition {
      condition     = local.jmeter_binaries_local_path != null
      error_message = "jmeter_binaries_local_path must be set or inferred from the configured JMeter download when jmeter_binaries_object_storage_upload_required is true."
    }
  }

  depends_on = [
    oci_objectstorage_bucket.jmeter_resources
  ]
}

resource "oci_objectstorage_preauthrequest" "jmeter_resources" {
  count = (var.jmeter_binaries_object_storage_upload_required ? 1 : 0)

  namespace             = data.oci_objectstorage_namespace.object_storage_namespace.namespace
  bucket                = local.jmeter_resources_bucket_name
  name                  = var.jmeter_resources_par_name
  access_type           = var.jmeter_resources_par_access_type
  bucket_listing_action = "ListObjects"
  time_expires          = var.jmeter_resources_par_time_expires

  depends_on = [
    oci_objectstorage_bucket.jmeter_resources,
    oci_objectstorage_object.jmeter_binaries
  ]

  lifecycle {
    ignore_changes = [
      bucket_listing_action
    ]
  }
}

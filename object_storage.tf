locals {

  downloaded_jmeter_resources_local_path = "${local.jmeter_resources_download_directory}/${local.jmeter_binaries_archive_name}"
  download_jmeter_resources              = (var.upload_jmeter_resources_to_object_storage && var.jmeter_resources_local_path == null)

  jmeter_binaries_archive_name = "apache-jmeter-${var.jmeter_version}.tgz"
  jmeter_binaries_object_name  = "binaries/${local.jmeter_binaries_archive_name}"

  jmeter_resources_bucket_name           = (var.upload_jmeter_resources_to_object_storage ? oci_objectstorage_bucket.jmeter_resources[0].name : var.jmeter_resources_bucket_name)
  jmeter_resources_bucket_compartment_id = (var.jmeter_resources_bucket_compartment_id != null ? var.jmeter_resources_bucket_compartment_id : var.nodes_compartment_id)

  jmeter_resources_download_directory = (var.jmeter_resources_download_directory != null ? var.jmeter_resources_download_directory : "${path.module}/.downloads")
  jmeter_resources_download_url       = "${var.jmeter_resources_url}/${local.jmeter_binaries_archive_name}"
  jmeter_resources_local_path         = (local.download_jmeter_resources ? data.external.download_jmeter_resources[0].result.path : var.jmeter_resources_local_path)
  jmeter_resources_par_url            = (var.upload_jmeter_resources_to_object_storage ? trimsuffix(oci_objectstorage_preauthrequest.jmeter_resources[0].full_path, "/") : trimsuffix(var.jmeter_resources_par_url, "/"))

  effective_jmeter_resources_url = (var.upload_jmeter_resources_to_object_storage ? "${trimsuffix(local.jmeter_resources_par_url, "/")}/binaries" : trimsuffix(var.jmeter_resources_url, "/"))
}

data "external" "download_jmeter_resources" {
  count = (local.download_jmeter_resources ? 1 : 0)

  program = [
    "${path.module}/scripts/download-jmeter-binaries",
    local.jmeter_resources_download_url,
    local.downloaded_jmeter_resources_local_path
  ]
}

resource "oci_objectstorage_bucket" "jmeter_resources" {
  count = (var.upload_jmeter_resources_to_object_storage ? 1 : 0)

  compartment_id = local.jmeter_resources_bucket_compartment_id
  namespace      = data.oci_objectstorage_namespace.object_storage_namespace.namespace
  name           = var.jmeter_resources_bucket_name
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
}

resource "oci_objectstorage_object" "jmeter_binaries" {
  count = (var.upload_jmeter_resources_to_object_storage ? 1 : 0)

  namespace    = data.oci_objectstorage_namespace.object_storage_namespace.namespace
  bucket       = local.jmeter_resources_bucket_name
  object       = local.jmeter_binaries_object_name
  source       = local.jmeter_resources_local_path
  content_type = var.jmeter_resources_object_content_type
  storage_tier = "InfrequentAccess"

  lifecycle {
    precondition {
      condition     = local.jmeter_resources_local_path != null
      error_message = "jmeter_resources_local_path must be set or inferred from the configured JMeter download when upload_jmeter_resources_to_object_storage is true."
    }
  }

  depends_on = [
    oci_objectstorage_bucket.jmeter_resources
  ]
}

resource "oci_objectstorage_preauthrequest" "jmeter_resources" {
  count = (var.upload_jmeter_resources_to_object_storage ? 1 : 0)

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

data "oci_identity_region_subscriptions" "regions" {

  tenancy_id = var.tenancy_ocid

  filter {
    name   = "region_name"
    values = [var.region]
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "services" {

  filter {
    name   = "cidr_block"
    values = [format("all-%s-services-in-oracle-services-network", lower(data.oci_identity_region_subscriptions.regions.region_subscriptions[0].region_key))]
  }
}

data "oci_objectstorage_namespace" "object_storage_namespace" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_subnet" "provided_jmeter_subnet" {
  count = (var.nodes_subnet_id != "" ? 1 : 0)

  subnet_id = var.nodes_subnet_id
}

data "oci_core_vcn" "jmeter_vcn" {
  vcn_id = var.nodes_subnet_id != "" ? data.oci_core_subnet.provided_jmeter_subnet[0].vcn_id : (var.nodes_vcn_id != "" ? var.nodes_vcn_id : oci_core_vcn.jmeter_vcn[0].id)
}

data "oci_core_subnet" "jmeter_subnet" {
  subnet_id = var.nodes_subnet_id != "" ? data.oci_core_subnet.provided_jmeter_subnet[0].id : oci_core_subnet.jmeter_subnet[0].id
}

data "oci_core_images" "ol8" {
  compartment_id = var.nodes_compartment_id

  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.nodes_shape
}


data "oci_core_image" "jmeter_nodes_image" {
  image_id = var.nodes_image_id != "" ? var.nodes_image_id : data.oci_core_images.ol8.images[0].id
}

data "oci_core_shapes" "flexible_shapes" {
  compartment_id = var.nodes_compartment_id
  image_id       = data.oci_core_image.jmeter_nodes_image.id
}

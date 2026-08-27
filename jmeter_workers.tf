resource "oci_core_instance" "jmeter_workers" {

  count = var.workers_count

  compartment_id      = var.nodes_compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name

  display_name = "${var.workers_display_name}-${format("%02d", count.index + 1)}"

  shape = var.nodes_shape

  dynamic "shape_config" {

    for_each = local.is_nodes_shape_flexible ? [1] : []

    content {

      ocpus         = var.nodes_ocpus
      memory_in_gbs = var.nodes_memory
    }
  }

  create_vnic_details {

    subnet_id = data.oci_core_subnet.jmeter_subnet.id

    assign_public_ip = false

    hostname_label = "${var.workers_hostname}-${format("%02d", count.index + 1)}"
    display_name   = "${var.workers_hostname}-${format("%02d", count.index + 1)}-vnic"
    nsg_ids        = [oci_core_network_security_group.jmeter_workers.id]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_image.jmeter_nodes_image.id
  }

  metadata = {

    ssh_authorized_keys = "${tls_private_key.controller_key_pair.public_key_openssh}${tls_private_key.workers_key_pair.public_key_openssh}"

    user_data = base64gzip(templatefile("${path.module}/cloud-init/cloud-init-workers.yaml", {
      jmeter-binaries-url     = local.jmeter_binaries_effective_url
      jmeter-version          = var.jmeter_version
      jmeter-port             = var.jmeter_port
      jmeter-jvm-heap-size    = local.jmeter_jvm_heap_size
      jmeter-jvm-permgen-size = local.jmeter_jvm_permgen_size
      jmeter-properties = base64encode(templatefile("${path.module}/cloud-init/jmeter/user-workers.properties", {
        jmeter-port = var.jmeter_port
      }))
    }))

    hostname = "${var.workers_hostname}-${format("%02d", count.index + 1)}"
  }

  agent_config {

    are_all_plugins_disabled = false

    is_management_disabled = false
    is_monitoring_disabled = false

    plugins_config {

      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }
}

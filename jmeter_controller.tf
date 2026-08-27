resource "oci_core_instance" "jmeter_controller" {

  depends_on = [oci_core_instance.jmeter_workers]

  # That's a trick for enabling iteration over created resources
  count = 1

  compartment_id = var.nodes_compartment_id

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name

  display_name = var.controller_display_name

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

    hostname_label = var.controller_hostname
    display_name   = "${var.controller_hostname}-vnic"
    nsg_ids        = [oci_core_network_security_group.jmeter_controller.id]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_image.jmeter_nodes_image.id
  }

  metadata = {

    ssh_authorized_keys = tls_private_key.controller_key_pair.public_key_openssh

    user_data = base64gzip(templatefile("${path.module}/cloud-init/cloud-init-controller.yaml", {
      ssh-identity        = base64encode(tls_private_key.workers_key_pair.private_key_pem)
      jmeter-binaries-url = local.jmeter_binaries_effective_url
      jmeter-version      = var.jmeter_version
      jmeter-sample-plan  = filebase64("${path.module}/cloud-init/jmeter/sample.jmx")
      jmeter-port         = var.jmeter_port
      client-port         = var.jmeter_client_port
      jmeter-properties = base64encode(templatefile("${path.module}/cloud-init/jmeter/user-controller.properties", {
        jmeter-remote-hosts = join(",", [for node in oci_core_instance.jmeter_workers : node.private_ip])
        jmeter-port         = var.jmeter_port
        client-port         = var.jmeter_client_port
      }))
      jmeter-test-script = base64encode(templatefile("${path.module}/cloud-init/jmeter/jmeter-test", {
        object-storage-repository-par-url = local.jmeter_resources_par_url
        jmeter-jvm-heap-size              = local.jmeter_jvm_heap_size
        jmeter-jvm-permgen-size           = local.jmeter_jvm_permgen_size
      }))
      jmeter-package-get-script = base64encode(templatefile("${path.module}/cloud-init/jmeter/jmeter-package-get", {
        object-storage-repository-par-url = local.jmeter_resources_par_url
      }))
      jmeter-package-list-script = base64encode(templatefile("${path.module}/cloud-init/jmeter/jmeter-package-list", {
        object-storage-repository-par-url = local.jmeter_resources_par_url
      }))
    }))

    hostname = var.controller_hostname
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

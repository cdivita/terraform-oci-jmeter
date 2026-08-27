locals {

  network_resources_compartment_id = (var.network_compartment_id != null && var.network_compartment_id != "" ? var.network_compartment_id : var.nodes_compartment_id)
  network_compartment_id           = (var.network_compartment_id != null && var.network_compartment_id != "" ? var.network_compartment_id : (var.nodes_subnet_id != "" ? data.oci_core_subnet.provided_jmeter_subnet[0].compartment_id : (var.nodes_vcn_id != "" ? data.oci_core_vcn.jmeter_vcn.compartment_id : local.network_resources_compartment_id)))
  create_nodes_vcn                 = (var.nodes_vcn_id == "" && var.nodes_subnet_id == "")
  nodes_subnet_cidr                = (var.nodes_subnet_id != "" ? data.oci_core_subnet.jmeter_subnet.cidr_block : var.nodes_subnet_cidr)
}

resource "oci_core_vcn" "jmeter_vcn" {

  count = (local.create_nodes_vcn ? 1 : 0)

  compartment_id = local.network_resources_compartment_id

  cidr_blocks = [var.nodes_vcn_cidr]

  display_name = var.nodes_vcn_name

  dns_label = var.nodes_vcn_dns_label
}

resource "oci_core_network_security_group" "jmeter_workers" {
  compartment_id = local.network_compartment_id

  vcn_id = data.oci_core_vcn.jmeter_vcn.id

  display_name = "jmeter-workers-nsg"
}

resource "oci_core_network_security_group_security_rule" "jmeter_workers" {
  network_security_group_id = oci_core_network_security_group.jmeter_workers.id

  description = "JMeter workers RMI connections"
  direction   = "INGRESS"
  protocol    = "6"

  source      = local.nodes_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = var.jmeter_port
      min = var.jmeter_port
    }
  }
}

resource "oci_core_network_security_group" "jmeter_controller" {
  compartment_id = local.network_compartment_id

  vcn_id = data.oci_core_vcn.jmeter_vcn.id

  display_name = "jmeter-controller-nsg"
}

resource "oci_core_network_security_group_security_rule" "jmeter_controller" {
  network_security_group_id = oci_core_network_security_group.jmeter_controller.id

  description = "JMeter controller RMI connections"
  direction   = "INGRESS"
  protocol    = "6"

  source      = local.nodes_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = var.jmeter_client_port
      max = var.jmeter_client_port + 2
    }
  }
}

resource "oci_core_service_gateway" "jmeter_vcn_service_gateway" {

  count = (local.create_nodes_vcn ? 1 : 0)

  compartment_id = local.network_resources_compartment_id

  vcn_id = data.oci_core_vcn.jmeter_vcn.id

  display_name = "service-gateway"

  services {
    service_id = data.oci_core_services.services.services[0].id
  }
}

resource "oci_core_nat_gateway" "jmeter_vcn_nat_gateway" {

  count          = (local.create_nodes_vcn ? 1 : 0)
  compartment_id = local.network_resources_compartment_id

  vcn_id = data.oci_core_vcn.jmeter_vcn.id

  display_name = "nat-gateway"
}

resource "oci_core_default_route_table" "jmeter_vcn_route_table" {

  count                      = (local.create_nodes_vcn ? 1 : 0)
  manage_default_resource_id = oci_core_vcn.jmeter_vcn[0].default_route_table_id

  route_rules {

    description = "Routing rule for forwarding traffic to NAT Gateway"

    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.jmeter_vcn_nat_gateway[0].id
  }

  route_rules {

    description = "Routing rule for forwarding to Service Gateway"

    destination       = data.oci_core_services.services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.jmeter_vcn_service_gateway[0].id
  }
}

resource "oci_core_subnet" "jmeter_subnet" {

  count          = (var.nodes_subnet_id != "" ? 0 : 1)
  compartment_id = local.network_compartment_id

  vcn_id     = data.oci_core_vcn.jmeter_vcn.id
  cidr_block = var.nodes_subnet_cidr

  display_name = var.nodes_subnet_name
  dns_label    = var.nodes_subnet_dns_label

  prohibit_public_ip_on_vnic = true

  security_list_ids = [data.oci_core_vcn.jmeter_vcn.default_security_list_id]
}

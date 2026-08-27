locals {

  bastion_compartment_id = (var.bastion_compartment_id != null && var.bastion_compartment_id != "" ? var.bastion_compartment_id : local.network_compartment_id)
}

resource "oci_bastion_bastion" "jmeter_bastion" {

  count = (var.create_bastion ? 1 : 0)

  compartment_id = local.bastion_compartment_id

  bastion_type = "STANDARD"

  name = var.bastion_name

  target_subnet_id = data.oci_core_subnet.jmeter_subnet.id

  client_cidr_block_allow_list = var.bastion_allowed_cidr_blocks

  max_session_ttl_in_seconds = var.bastion_session_max_ttl
}

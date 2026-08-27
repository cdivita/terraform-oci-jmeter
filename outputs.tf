output "jmeter" {

  value = {

    nodes = {

      bastion_id = length(oci_bastion_bastion.jmeter_bastion) > 0 ? oci_bastion_bastion.jmeter_bastion[0].id : null
      controller = { for c in oci_core_instance.jmeter_controller : c.metadata.hostname => { id : c.id, private-ip : c.private_ip } }
      workers    = { for w in oci_core_instance.jmeter_workers : w.metadata.hostname => { id : w.id, private-ip : w.private_ip } }
    }

    object_storage = {
      jmeter_binaries_object_name  = var.jmeter_binaries_object_storage_upload_required ? local.jmeter_binaries_object_name : null
      jmeter_resources_bucket_name = var.jmeter_binaries_object_storage_upload_required ? local.jmeter_resources_bucket_name : null
      jmeter_resources_par_url     = local.jmeter_resources_par_url
    }
  }
}

output "security" {

  sensitive = true

  value = {
    key_pairs = {
      controller = {
        private_key = tls_private_key.controller_key_pair.private_key_pem
        public_key  = tls_private_key.controller_key_pair.public_key_openssh
      }

      workers = {
        private_key = tls_private_key.workers_key_pair.private_key_pem
        public_key  = tls_private_key.workers_key_pair.public_key_openssh
      }
    }
  }
}

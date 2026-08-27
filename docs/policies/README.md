# OCI Policies

The exact policies depend on whether the module creates network resources, reuses existing network resources, creates a bastion, and creates Object Storage resources.

The examples below use placeholders:

- `<group-name>`: IAM group running Terraform.
- `<nodes-compartment>`: compartment containing the controller and worker instances.
- `<network-compartment>`: compartment containing the VCN, subnet, gateways, and NSGs.
- `<resources-compartment>`: compartment containing the Object Storage bucket.
- `<bastion-compartment>`: compartment containing the OCI Bastion.

When all resources are created in the same compartment, use the same compartment name in each statement.

## Common Policies

These are required in all scenarios because the module creates compute instances and reads image, shape, availability domain, region, and Object Storage namespace data.

```text
allow group <group-name> to manage instance-family in compartment <nodes-compartment>
allow group <group-name> to use volume-family in compartment <nodes-compartment>
allow group <group-name> to inspect compartments in tenancy
allow group <group-name> to inspect tenancies in tenancy
```

If images are read from a different compartment, allow image read access there too:

```text
allow group <group-name> to read instance-images in compartment <image-compartment>
```

## Create New VCN And Subnet

Required when `nodes_vcn_id = ""` and `nodes_subnet_id = ""`.

```text
allow group <group-name> to manage virtual-network-family in compartment <network-compartment>
```

This covers the VCN, subnet, NAT Gateway, Service Gateway, route table updates, NSGs, VNICs, and related network resources created by the module.

## Reuse Existing VCN

Required when `nodes_vcn_id` is provided and `nodes_subnet_id = ""`.

```text
allow group <group-name> to read virtual-network-family in compartment <network-compartment>
allow group <group-name> to manage subnets in compartment <network-compartment>
allow group <group-name> to manage network-security-groups in compartment <network-compartment>
allow group <group-name> to use vnics in compartment <network-compartment>
```

The module reads the existing VCN and creates the JMeter subnet and NSGs.

## Reuse Existing Subnet

Required when `nodes_subnet_id` is provided.

```text
allow group <group-name> to read vcns in compartment <network-compartment>
allow group <group-name> to read subnets in compartment <network-compartment>
allow group <group-name> to manage network-security-groups in compartment <network-compartment>
allow group <group-name> to use vnics in compartment <network-compartment>
```

The module reads the existing subnet and VCN, then creates NSGs and attaches them to controller and worker VNICs.

## Create Bastion

Required when `create_bastion = true`.

```text
allow group <group-name> to manage bastion-family in compartment <bastion-compartment>
allow group <group-name> to read virtual-network-family in compartment <network-compartment>
allow group <group-name> to read instance-family in compartment <nodes-compartment>
allow group <group-name> to read instance-agent-plugins in compartment <nodes-compartment>
allow group <group-name> to inspect work-requests in tenancy
```

If bastion sessions are created by users outside Terraform, those users also need permissions to use the bastion and manage bastion sessions, plus read access to the target network and instances.

## Create Object Storage Resources

Required when `jmeter_binaries_object_storage_upload_required = true`.

```text
allow group <group-name> to manage object-family in compartment <resources-compartment>
```

This covers bucket creation, object upload, object reads/writes, listing, and pre-authenticated request management.

If Object Storage resources are not created by this module and `jmeter_resources_par_url` is provided, Terraform does not need object management permissions for that bucket.

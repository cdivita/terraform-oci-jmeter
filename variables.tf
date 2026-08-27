variable "region" {

  description = "Region of the Tenancy"
  type        = string
}

variable "tenancy_ocid" {

  description = "OCID of the Tenancy"
  type        = string
}

variable "current_user_ocid" {

  # Where to Get the Tenancy's OCID and User's OCID: https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
  description = "The user OCID. Required when configuring the OCI provider with explicit API key variables."
  type        = string
  default     = null
}

variable "oci_config_file_profile" {

  description = "OCI CLI config profile to use for provider authentication. Set to null when using explicit API key variables or environment-based authentication."
  type        = string
  default     = null
}

variable "oci_api_key_fingerprint" {

  description = "Fingerprint of the OCI API signing key. Required when configuring the OCI provider with explicit API key variables."
  type        = string
  default     = null
}

variable "oci_api_private_key_path" {

  description = "Path to the OCI API signing private key. Required when configuring the OCI provider with explicit API key variables."
  type        = string
  default     = null
}

variable "network_compartment_id" {

  description = "OCID of the compartment where creating JMeter network resources"
  type        = string
  default     = ""
}

variable "nodes_vcn_id" {

  description = "OCID of the VCN where to deploy JMeter nodes"
  type        = string
  default     = ""
}

variable "nodes_vcn_name" {

  description = "Name of the VCN where to deploy JMeter nodes"
  type        = string
  default     = "jmeter-vcn"
}

variable "nodes_vcn_cidr" {

  description = "The CIDR of the VCN where to deploy JMeter nodes"
  type        = string
  default     = "172.17.240.0/24"
}

variable "nodes_vcn_dns_label" {

  description = "The DNS label of the VCN where to deploy JMeter nodes"
  type        = string
  default     = "jmeter"
}

variable "nodes_subnet_id" {

  description = "OCID of the subnet (private) where the JMeter nodes are instantiated"
  type        = string
  default     = ""
}

variable "nodes_subnet_name" {

  description = "Name of the subnet (private) to create for JMeter nodes"
  type        = string
  default     = "nodes"
}

variable "nodes_subnet_cidr" {

  description = "The CIDR of the subnet (private) to create for JMeter nodes"
  type        = string
  default     = "172.17.240.0/24"
}

variable "nodes_subnet_dns_label" {

  description = "The DNS label of the subnet (private) to create for JMeter nodes"
  type        = string
  default     = "nodes"
}

variable "nodes_compartment_id" {

  description = "OCID of the compartment where creating the JMeter nodes"
  type        = string
}

variable "nodes_image_id" {

  description = "The OCID of the image used for JMeter nodes"
  type        = string
  default     = ""
}

variable "nodes_shape" {

  description = "The shape used for JMeter nodes"
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "nodes_ocpus" {

  description = "The number of OCPUs used by a JMeter nodes"
  type        = number
  default     = 1
}

variable "nodes_memory" {

  description = "The memory assigned to a JMeter node"
  type        = number
  default     = 32
}

variable "controller_display_name" {

  description = "The display name of JMeter controller"
  type        = string
  default     = "jmeter-controller"
}

variable "controller_hostname" {

  description = "The hostname of JMeter controller"
  type        = string
  default     = "jmeter-controller"
}

variable "workers_display_name" {

  description = "The name of JMeter controller"
  type        = string
  default     = "jmeter-worker"
}

variable "workers_hostname" {

  description = "The base hostname used for JMeter workers"
  type        = string
  default     = "jmeter-worker"
}

variable "workers_count" {

  description = "The number of JMeter workers to create"
  type        = number
  default     = 2
}

variable "jmeter_binaries_base_url" {

  description = "Base URL where to download Apache JMeter binaries"
  type        = string

  default = "https://downloads.apache.org/jmeter/binaries"
}

variable "jmeter_binaries_object_storage_upload_required" {

  description = "Whether to download JMeter binaries when needed, upload them to Object Storage, and create the bucket, object, and PAR resources"
  type        = bool

  default = false
}

variable "jmeter_resources_bucket_compartment_id" {

  description = "OCID of the compartment where creating the Object Storage bucket for JMeter resources"
  type        = string

  default = null
}

variable "jmeter_resources_bucket_name" {

  description = "Name of the Object Storage bucket for JMeter resources"
  type        = string

  default = "jmeter-resources"
}

variable "jmeter_binaries_download_directory" {

  description = "Local directory where Terraform downloads the configured JMeter binaries archive"
  type        = string

  default = null
}

variable "jmeter_binaries_local_path" {

  description = "Local path of the downloaded JMeter binaries archive to upload to Object Storage"
  type        = string

  default = null
}

variable "jmeter_resources_object_content_type" {

  description = "Content type to assign to the uploaded JMeter resources archive"
  type        = string

  default = "application/gzip"
}

variable "jmeter_resources_par_name" {

  description = "Name of the pre-authenticated request for the JMeter resources Object Storage bucket"
  type        = string

  default = "jmeter-resources-par"
}

variable "jmeter_resources_par_access_type" {

  description = "Access type of the pre-authenticated request for the JMeter resources Object Storage bucket"
  type        = string

  default = "AnyObjectReadWrite"
}

variable "jmeter_resources_par_time_expires" {

  description = "Expiration timestamp of the JMeter resources bucket pre-authenticated request in RFC3339 format"
  type        = string

  default = "2099-12-31T23:59:59Z"
}

variable "jmeter_version" {

  description = "The JMeter version to install on nodes"
  type        = string

  default = "5.6.3"
}

variable "jmeter_port" {

  description = "The RMI port used by JMeter workers"
  type        = number

  default = 1099
}

variable "jmeter_client_port" {

  description = "The RMI port used by JMeter workers for communicating with the JMeter controller"
  type        = number

  default = 4000
}

variable "jmeter_resources_par_url" {

  description = "The PAR URL of the Object Storage bucket used for JMeter resources when not creating it in this module"
  type        = string

  default = ""
}

variable "create_bastion" {

  description = "Whether to create a bastion for accessing JMeter nodes"
  type        = bool

  default = true
}

variable "bastion_name" {

  description = "The name of the bastion for accessing to JMeter nodes"
  type        = string

  default = "jmeter-bastion"
}

variable "bastion_compartment_id" {

  description = "OCID of the compartment where to create the bastion for accessing to JMeter nodes"
  type        = string

  default = null
}

variable "bastion_allowed_cidr_blocks" {

  description = "The list of CIDR ranges allowed for connecting to the bastion for accessing to JMeter nodes"
  type        = list(string)

  default = ["0.0.0.0/0"]
}

variable "bastion_session_max_ttl" {

  description = "TTL of the sessions created with the bastion for accessing to JMeter nodes"
  type        = number

  default = 60 * 60 * 3
}

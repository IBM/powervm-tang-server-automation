################################################################
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2022
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################

################################################################
# Configure the OpenStack Provider
################################################################
variable "user_name" {
  description = "The user name used to connect to OpenStack/PowerVC"
  default     = "****"
}

variable "password" {
  description = "The password for the user"
  default     = "****"
}

variable "tenant_name" {
  description = "The name of the project (a.k.a. tenant) used"
  default     = "ibm-default"
}

variable "domain_name" {
  description = "The domain to be used"
  default     = "Default"
}

variable "auth_url" {
  description = "The endpoint URL used to connect to OpenStack/PowerVC"
  default     = "https://<HOSTNAME>:5000/v3/"
}

variable "insecure" {
  default = "true" # Default is INSECURE
}

variable "openstack_availability_zone" {
  description = "The name of Availability Zone for deploy operation"
  default     = ""
}

################################################################
# Configure the Instance details
################################################################

variable "bastion" {
  # only one node is supported
  default = {
    count         = 1
    instance_type = "ocp4-medium"
    image_id      = "daa5d3f4-ab66-4b2d-9f3d-77bd61774419"
  }
  validation {
    condition     = lookup(var.bastion, "count", 1) == 1
    error_message = "The bastion.count value must be either 1 or 2."
  }
}

variable "bastion_public_ip" {
  type        = string
  description = "The bastion_public_ip is the IP used to deploy the NBDE servers when the bastion.count = 0, and uses a pre-existing bastion host"
  default     = ""
}

variable "tang" {
  # only three nodes are supported
  default = {
    count         = 3
    instance_type = "ocp4-medium"
    image_id      = "468863e6-4b33-4e8b-b2c5-c9ef9e6eedf4"

    # optional availability_zone
    # availability_zone = ""
    # optional fixed IPs
    # fixed_ips = []
    # optional data volumes to master nodes
    data_volume_size  = 10 #Default volume size (in GB) to be attached to the master nodes.
    data_volume_count = 1  #Number of volumes to be attached to each master node.
  }
  validation {
    condition     = lookup(var.tang, "count", 3) == 3
    error_message = "The tang.count value must be 3."
  }
  validation {
    condition     = lookup(var.tang, "data_volume_count", 1) == 1
    error_message = "The tang.data_volume_count must be 1."
  }
}

variable "network_name" {
  description = "The name of the network to be used for deploy operations"
  default     = "my_network_tang"
}

variable "network_type" {
  #Eg: SEA or SRIOV
  default     = "SEA"
  description = "Specify the name of the network adapter type to use for creating hosts"
}

variable "sriov_vnic_failover_vfs" {
  # Eg: 1 = VNIC without failover; 2 = VNIC failover with 2 SR-IOV VFs
  default     = 1
  description = "Specifies the amount of VNIC failover virtual functions (max. is 6)"
  validation {
    condition     = var.sriov_vnic_failover_vfs > 0 && var.sriov_vnic_failover_vfs < 7
    error_message = "The number of virtual functions for the parameter sriov_vnic_failover_vfs must be min. 1 and cannot exceed 6."
  }
}

variable "scg_id" {
  description = "The id of PowerVC Storage Connectivity Group to use for all nodes"
  default     = ""
}

variable "sriov_capacity" {
  # Eg: 0.02 = 2%; 0.20 = 20%; 1.00 = 100%
  default     = 0.02
  description = "Specifies the SR-IOV LP capacity"
}

variable "rhel_username" {
  default = "root"
}

variable "rhel_image_name" {
  description = "Name of the RHEL image that you want to use for the bastion node"
  default     = "rhel-8.6"
}

variable "keypair_name" {
  # Set this variable to the name of an already generated
  # keypair to use it instead of creating a new one.
  default = ""
}

variable "public_key_file" {
  description = "Path to public key file"
  # if empty, will default to ${path.cwd}/data/id_rsa.pub
  default = "data/id_rsa.pub"
}

variable "private_key_file" {
  description = "Path to private key file"
  # if empty, will default to ${path.cwd}/data/id_rsa
  default = "data/id_rsa"
}

# sensitive is not used, as we loose a lot of logging.
variable "private_key" {
  description = "content of private ssh key"
  # if empty string will read contents of file at var.private_key_file
  default = ""
}

variable "public_key" {
  description = "Public key"
  # if empty string will read contents of file at var.public_key_file
  default = ""
}

variable "rhel_subscription_username" {
  default = ""
}

variable "rhel_subscription_password" {
  default = ""
}

variable "rhel_smt" {
  description = "SMT value to set on the node. Eg: on,off,2,4,8"
  default     = 8
}

################################################################
### Instrumentation
################################################################
variable "ssh_agent" {
  description = "Enable or disable SSH Agent. Can correct some connectivity issues. Default: false"
  default     = false
}

variable "bastion_health_status" {
  type        = string
  description = "Specify if bastion should poll for the Health Status to be OK or WARNING. Default is OK."
  default     = "OK"
  validation {
    condition     = contains(["OK", "WARNING"], var.bastion_health_status)
    error_message = "The bastion_health_status value must be either OK or WARNING."
  }
}

variable "dns_forwarders" {
  default = "8.8.8.8; 8.8.4.4"
}

# Must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character
# Should not be more than 14 characters
variable "vm_id_prefix" {
  default = "tang"
}
# Must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character
# Length cannot exceed 14 characters when combined with cluster_id_prefix
variable "vm_id" {
  default = ""
}

variable "proxy" {
  type        = object({})
  description = "External Proxy server details in a map"
  default     = {}
  #    default = {
  #        server = "10.10.1.166",
  #        port = "3128"
  #        user = "pxuser",
  #        password = "pxpassword"
  #    }
}

variable "cluster_id" {
  type    = string
  default = ""

  validation {
    condition     = can(regex("^$|^[a-z0-9]+[a-zA-Z0-9_\\-.]*[a-z0-9]+$", var.cluster_id))
    error_message = "The cluster_id value must be a lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character."
  }

  validation {
    condition     = length(var.cluster_id) <= 14
    error_message = "The cluster_id value shouldn't be greater than 14 characters."
  }
}

variable "domain" {
  type        = string
  default     = "ibm.com"
  description = "Domain name to use to setup the cluster. A DNS Forward Zone should be a registered in IBM Cloud if use_ibm_cloud_services = true"

  validation {
    condition     = can(regex("^[a-z0-9]+[a-zA-Z0-9_\\-.]*[a-z0-9]+$", var.domain))
    error_message = "The domain value must be a lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character."
  }
}

variable "name_prefix" {
  type    = string
  default = ""

  validation {
    condition     = length(var.name_prefix) <= 32
    error_message = "Length cannot exceed 32 characters for name_prefix."
  }
}

variable "connection_timeout" {
  description = "Timeout in minutes for SSH connections"
  default     = 30
}

variable "private_network_mtu" {
  type        = number
  description = "MTU value for the private network interface on RHEL and RHCOS nodes"
  default     = 1450
}

variable "rhel_subscription_org" {
  type    = string
  default = ""
}

variable "setup_squid_proxy" {
  type        = bool
  description = "Flag to install and configure squid proxy server on bastion node"
  default     = false
}

variable "rhel_subscription_activationkey" {
  type    = string
  default = "The subscription key for activating rhel"
}

variable "ansible_repo_name" {
  default     = "ansible-2.9-for-rhel-8-ppc64le-rpms"
  description = "The Ansible repository name"
}

variable "tang_health_status" {
  default = "WARNING"
}

################################################################
### Fips Configuration
################################################################
variable "fips_compliant" {
  type        = bool
  description = "Set to true to enable usage of FIPS for the deployment."
  default     = false
}

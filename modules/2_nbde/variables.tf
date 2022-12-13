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

# From the Bastion Setup
variable "bastion_public_ip" { type = string }

variable "rhel_image_name" {
  description = "Name of the RHEL image that you want to use for the bastion node"
  default     = "rhel-8.6"
}

variable "network_name" {
  description = "The name of the network to be used for deploy operations"
  default     = "my_network_tang"
}

variable "rhel_username" {
  default = "root"
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

variable "private_key" {
  description = "content of private ssh key"
  # if empty string will read contents of file at var.private_key_file
  default   = ""
}

variable "public_key" {
  description = "Public key"
  # if empty string will read contents of file at var.public_key_file
  default   = ""
}

variable "rhel_subscription_username" {
  default   = ""
}

variable "rhel_subscription_password" {
  default   = ""
}

variable "rhel_smt" {
  description = "SMT value to set on the bastion node. Eg: on,off,2,4,8"
  default     = 4
}

################################################################
### Instrumentation
################################################################
variable "ssh_agent" {
  description = "Enable or disable SSH Agent. Can correct some connectivity issues. Default: false"
  default     = false
}

variable "dns_forwarders" {
  default = "8.8.8.8; 8.8.4.4"
}

# Must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character
# Should not be more than 14 characters
variable "vm_id_prefix" {
  default = "infra-node"
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
  type = string
}

variable "name_prefix" {
  type = string

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
  type      = string
  default   = ""
}

variable "setup_squid_proxy" {
  type        = bool
  description = "Flag to install and configure squid proxy server on bastion node"
  default     = false
}

variable "rhel_subscription_activationkey" {
  type      = string
  default   = ""
}

variable "ansible_repo_name" {
  default = "ansible-2.9-for-rhel-8-ppc64le-rpms"
}

variable "tang_health_status" {
  default = "WARNING"
}

variable "tang" {
  # only three nodes are supported
  default = {
    count         = 3
    instance_type = "m1.xlarge"
    # rhcos image id
    image_id = "468863e6-4b33-4e8b-b2c5-c9ef9e6eedf4"
    # optional availability_zone
    # availability_zone = ""
    # optional fixed IPs
    # fixed_ips = []
    # optional data volumes to master nodes
    # data_volume_size = 100 #Default volume size (in GB) to be attached to the master nodes.
    # data_volume_count = 0 #Number of volumes to be attached to each master node.
  }
  validation {
    condition     = lookup(var.tang, "count", 3) == 3
    error_message = "The tang.count value must be 3."
  }
}

variable "key_pair" {
  type = string
}

variable "openstack_availability_zone" {
  description = "The name of Availability Zone for deploy operation"
  default     = ""
}
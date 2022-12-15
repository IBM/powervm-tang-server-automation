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

variable "bastion" {
  # only one node is supported
  default = {
    count         = 1
    instance_type = "m1.xlarge"
    image_id      = "daa5d3f4-ab66-4b2d-9f3d-77bd61774419"
  }
  validation {
    condition     = lookup(var.bastion, "count", 1) == 1
    error_message = "The bastion.count value must be either 1 or 2."
  }
}

variable "rhel_image_name" {
  description = "Name of the RHEL image that you want to use for the bastion node"
  default     = "rhel-8.6"
}

variable "network_name" {
  description = "The name of the network to be used for deploy operations"
  default     = "ocp-net"
}

variable "dns_forwarders" {
  default = "8.8.8.8; 8.8.4.4"
}

variable "name_prefix" {
  default = ""
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

variable "ansible_repo_name" {
  default = "ansible-2.9-for-rhel-8-ppc64le-rpms"
}

variable "rhel_subscription_username" {
  default   = ""
  sensitive = true
}

variable "rhel_subscription_password" {
  default   = ""
  sensitive = true
}
variable "rhel_subscription_org" {
  type      = string
  default   = ""
  sensitive = true
}

variable "rhel_subscription_activationkey" {
  type      = string
  default   = ""
  sensitive = true
}
variable "domain" {}
variable "rhel_smt" {}

variable "setup_squid_proxy" {
  type        = bool
  description = "Flag to install and configure squid proxy server on bastion node"
  default     = false
}
variable "proxy" {
  type        = object({})
  description = "External Proxy server details in a map"
  default = {
    server    = "",
    port      = ""
    user      = "",
    user_pass = ""
    no_proxy  = ""
  }
  #    default = {
  #        server = "10.10.1.166",
  #        port = "3128"
  #        user = "pxuser",
  #        user_pass = "pxpassword"
  #    }
}
################################################################
# Configure the SSH Settings
################################################################

variable "rhel_username" {
  default = "root"
}

variable "private_key" {
  type        = string
  description = "private key"
  default     = ""
  sensitive   = true
}

variable "public_key" {
  type        = string
  description = "public key"
  default     = ""
  sensitive   = true
}

variable "connection_timeout" {
  description = "Timeout in minutes for SSH connections"
  default     = 15
}

variable "ssh_agent" {
  description = "Enable or disable SSH Agent. Can correct some connectivity issues. Default: false"
  default     = false
}

variable "private_network_mtu" {
  type        = number
  description = "MTU value for the private network interface on RHEL and RHCOS nodes"
  default     = 1450
}

variable "key_pair" {
  type = string
}

variable "openstack_availability_zone" {
  description = "The name of Availability Zone for deploy operation"
  default     = ""
  sensitive   = true
}
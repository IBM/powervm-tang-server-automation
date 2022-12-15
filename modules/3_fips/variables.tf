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
# Configure the Bastion Instance details
################################################################

variable "bastion_count" { type = number }
variable "bastion_public_ip" { type = string }

################################################################
# Configure the Tang Instance details
################################################################

variable "tang_count" {}
variable "tang_instance_ids" {
  default = {
    count    = 1
    inst_ids = ""
  }
}
variable "tang_ips" {
  default = ""
}

################################################################
# Configure the SSH Settings
################################################################

variable "rhel_username" {
  default = "root"
}

variable "private_key" {
  description = "content of private ssh key"
  default     = ""
  sensitive   = true
}

variable "connection_timeout" {
  description = "Timeout in minutes for SSH connections"
  default     = 5
}

variable "ssh_agent" {
  description = "Enable or disable SSH Agent. Can correct some connectivity issues. Default: false"
  default     = false
}
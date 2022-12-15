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

resource "random_id" "label" {
  count       = var.vm_id == "" ? 1 : 0
  byte_length = "2" # Since we use the hex, the word lenght would double
  prefix      = "${var.vm_id_prefix}-"
}

# Figures out the key files
locals {
  # Generates vm_id as combination of vm_id_prefix + (random_id or user-defined vm_id)
  n_prefix = var.name_prefix == "" ? random_id.label[0].hex : "${var.name_prefix}"

  private_key_file = var.private_key_file == "" ? "${path.cwd}/data/id_rsa" : "${path.cwd}/${var.private_key_file}"
  public_key_file  = var.public_key_file == "" ? "${path.cwd}/data/id_rsa.pub" : "${path.cwd}/${var.public_key_file}"
  private_key      = var.private_key == "" ? file(coalesce(local.private_key_file, "/dev/null")) : var.private_key
  public_key       = var.public_key == "" ? file(coalesce(local.public_key_file, "/dev/null")) : var.public_key
  create_keypair   = var.keypair_name == "" ? "1" : "0"
}

provider "openstack" {
  user_name   = var.user_name
  password    = var.password
  tenant_name = var.tenant_name
  domain_name = var.domain_name
  auth_url    = var.auth_url
  insecure    = var.insecure
}

resource "openstack_compute_keypair_v2" "kp" {
  count      = local.create_keypair
  name       = var.keypair_name == "" ? "${local.n_prefix}-keypair" : var.keypair_name
  public_key = local.public_key
}

module "bastion" {
  # If the bastion.count is zero, then we're skipping as the bastion already exists
  count  = var.bastion.count >= 1 ? 1 : 0
  source = "./modules/1_bastion/"

  providers = {
    openstack = openstack
  }

  bastion                         = var.bastion
  rhel_image_name                 = var.rhel_image_name
  network_name                    = var.network_name
  dns_forwarders                  = var.dns_forwarders
  name_prefix                     = local.n_prefix
  bastion_health_status           = var.bastion_health_status
  ansible_repo_name               = var.ansible_repo_name
  rhel_subscription_username      = var.rhel_subscription_username
  rhel_subscription_password      = var.rhel_subscription_password
  rhel_subscription_org           = var.rhel_subscription_org
  rhel_subscription_activationkey = var.rhel_subscription_activationkey
  domain                          = var.domain
  rhel_smt                        = var.rhel_smt
  setup_squid_proxy               = var.setup_squid_proxy
  proxy                           = var.proxy
  rhel_username                   = var.rhel_username

  openstack_availability_zone = var.openstack_availability_zone
  key_pair                    = var.keypair_name == "" ? "${local.n_prefix}-keypair" : var.keypair_name
  private_key                 = local.private_key
  public_key                  = local.public_key
  connection_timeout          = var.connection_timeout
  ssh_agent                   = var.ssh_agent
  private_network_mtu         = var.private_network_mtu
}

module "nbde" {
  source = "./modules/2_nbde"

  providers = {
    openstack = openstack
  }

  depends_on = [
    module.bastion,
  ]

  # Bastion Public IP is either from the vars file or from the prior module
  bastion_public_ip = var.bastion_public_ip == "" ? module.bastion[0].bastion_public_ip : var.bastion_public_ip

  # Tang Setup
  tang                            = var.tang
  rhel_image_name                 = var.rhel_image_name
  network_name                    = var.network_name
  dns_forwarders                  = var.dns_forwarders
  name_prefix                     = local.n_prefix
  tang_health_status              = var.tang_health_status
  ansible_repo_name               = var.ansible_repo_name
  rhel_subscription_username      = var.rhel_subscription_username
  rhel_subscription_password      = var.rhel_subscription_password
  rhel_subscription_org           = var.rhel_subscription_org
  rhel_subscription_activationkey = var.rhel_subscription_activationkey
  domain                          = var.domain
  rhel_smt                        = var.rhel_smt
  setup_squid_proxy               = var.setup_squid_proxy
  proxy                           = var.proxy
  rhel_username                   = var.rhel_username

  openstack_availability_zone = var.openstack_availability_zone
  key_pair                    = var.keypair_name == "" ? "${local.n_prefix}-keypair" : var.keypair_name
  private_key                 = local.private_key
  connection_timeout          = var.connection_timeout
  ssh_agent                   = var.ssh_agent
  private_network_mtu         = var.private_network_mtu
}

locals {
  tang_ips = module.nbde.tang_ips
}

module "fips" {
  count  = var.fips_compliant ? 1 : 0
  source = "./modules/3_fips"

  providers = {
    openstack = openstack
  }

  depends_on = [
    module.bastion,
    module.nbde
  ]

  # Bastion
  bastion_count     = lookup(var.bastion, "count", 1)
  bastion_public_ip = module.bastion[0].bastion_public_ip

  # Tang
  tang_count = lookup(var.tang, "count", 1)
  tang_ips   = local.tang_ips

  # RHEL
  rhel_username      = var.rhel_username
  private_key        = local.private_key
  ssh_agent          = var.ssh_agent
  connection_timeout = var.connection_timeout
}
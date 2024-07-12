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
# © Copyright IBM Corp. 2022, 2023
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################

locals {
  private_key = var.private_key

  proxy = {
    server    = lookup(var.proxy, "server", ""),
    port      = lookup(var.proxy, "port", "3128"),
    user      = lookup(var.proxy, "user", ""),
    password  = lookup(var.proxy, "password", "")
    user_pass = lookup(var.proxy, "user", "") == "" ? "" : "${lookup(var.proxy, "user", "")}:${lookup(var.proxy, "password", "")}@"
    no_proxy  = "127.0.0.1,localhost,.${var.cluster_id}.${var.domain}"
  }
}

data "openstack_compute_flavor_v2" "tang" {
  name = var.tang["instance_type"]
}

data "openstack_networking_network_v2" "network" {
  name = var.network_name
}

# docs - https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2
resource "openstack_compute_instance_v2" "tang" {
  count = var.tang.count
  name  = "${var.name_prefix}-server-${count.index}"

  image_id  = var.tang["image_id"]
  flavor_id = data.openstack_compute_flavor_v2.tang.flavor_id
  key_pair  = var.key_pair
  network {
    name = data.openstack_networking_network_v2.network.name
  }

  availability_zone = lookup(var.tang, "availability_zone", var.openstack_availability_zone)
}

# Extract the instance's IP addresses
locals {
  tang_hosts = join(",", [for ts in openstack_compute_instance_v2.tang : ts.network[0].fixed_ip_v4])
  tang = {
    volume_count = lookup(var.tang, "data_volume_count", 1),
    volume_size  = lookup(var.tang, "data_volume_size", 10)
  }
}

resource "openstack_blockstorage_volume_v3" "tang" {
  depends_on = [openstack_compute_instance_v2.tang]
  count      = local.tang.volume_count * var.tang["count"]
  name       = "${var.cluster_id}-tang-${count.index}-volume"
  size       = local.tang.volume_size
}

resource "openstack_compute_volume_attach_v2" "tang" {
  count       = local.tang.volume_count * var.tang["count"]
  instance_id = openstack_compute_instance_v2.tang.*.id[floor(count.index / local.tang.volume_count)]
  volume_id   = openstack_blockstorage_volume_v3.tang.*.id[count.index]
}

# Accounts for server setup delays before executing the nbde role
resource "null_resource" "tang_server_nop" {
  count      = var.tang["count"]
  depends_on = [openstack_compute_volume_attach_v2.tang]

  triggers = {
    external_ip        = openstack_compute_instance_v2.tang[count.index].network[0].fixed_ip_v4
    rhel_username      = var.rhel_username
    private_key        = local.private_key
    ssh_agent          = var.ssh_agent
    connection_timeout = "${var.connection_timeout}m"
  }

  connection {
    type        = "ssh"
    user        = self.triggers.rhel_username
    host        = self.triggers.external_ip
    private_key = self.triggers.private_key
    agent       = self.triggers.ssh_agent
    timeout     = self.triggers.connection_timeout
  }

  provisioner "remote-exec" {
    inline = [
      "whoami"
    ]
  }
}

resource "null_resource" "tang_setup" {
  count = 1

  depends_on = [
    openstack_compute_volume_attach_v2.tang, null_resource.tang_server_nop
  ]

  triggers = {
    external_ip        = var.bastion_public_ip
    rhel_username      = var.rhel_username
    private_key        = local.private_key
    ssh_agent          = var.ssh_agent
    connection_timeout = "${var.connection_timeout}m"
  }

  connection {
    type        = "ssh"
    user        = self.triggers.rhel_username
    host        = self.triggers.external_ip
    private_key = self.triggers.private_key
    agent       = self.triggers.ssh_agent
    timeout     = self.triggers.connection_timeout
  }

  # Copy over the files into the existing playbook and ensures the names are unique
  provisioner "file" {
    source      = "${path.cwd}/modules/2_nbde/files/setup.yml"
    destination = "setup.yml"
  }

  provisioner "file" {
    source      = "${path.cwd}/modules/2_nbde/files/tang.yml"
    destination = "tang.yml"
  }

  provisioner "file" {
    source      = "${path.cwd}/modules/2_nbde/files/volume-mount.yml"
    destination = "volume-mount.yml"
  }

  provisioner "file" {
    source      = "${path.cwd}/modules/2_nbde/files/remove-subscription.yml"
    destination = "remove-subscription.yml"
  }

  # Added quotes to avoid globbing issues in the extra-vars
  provisioner "remote-exec" {
    when = create
    inline = [
      <<EOF
echo "Hosts: ${local.tang_hosts}"
echo "[vmhost],${local.tang_hosts}" | tr "," "\n\t" > inventory

cat << EOT > ansible.cfg
[defaults]
retry_files_enabled = False
pipelining          = True
host_key_checking   = False
log_path            = /root/tang-setup-logs.txt
EOT

echo 'Running tang setup playbook...'
ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory setup.yml \
  --extra-vars username="${var.rhel_subscription_username}" \
  --extra-vars password="${var.rhel_subscription_password}" \
  --extra-vars bastion_ip="$(ip -4 -json addr show dev env32  | jq -r '.[].addr_info[].local')" \
  --extra-vars rhel_subscription_org="${var.rhel_subscription_org}" \
  --extra-vars ansible_repo_name="${var.ansible_repo_name}" \
  --extra-vars rhel_subscription_activationkey="${var.rhel_subscription_activationkey}" \
  --extra-vars proxy_user="${local.proxy.user}" \
  --extra-vars proxy_user_pass="${local.proxy.user_pass}" \
  --extra-vars proxy_server="${local.proxy.server}" \
  --extra-vars proxy_port="${local.proxy.port}" \
  --extra-vars no_proxy="${local.proxy.no_proxy}" \
  --extra-vars private_network_mtu="${var.private_network_mtu}"  \
  --extra-vars domain="${var.domain}"
EOF
    ]
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      <<EOF
cat << EOT > ansible.cfg
[defaults]
retry_files_enabled = False
pipelining          = True
host_key_checking   = False
log_path            = /root/tang-volume-mount-logs.txt
EOT

ansible-galaxy collection install community.general:6.5.0 ansible.posix:1.5.1
ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory volume-mount.yml
EOF
    ]
  }

  # destroy optimistically destroys the subscription (if it fails, and it can it pipes to true to shortcircuit)
  provisioner "remote-exec" {
    when       = destroy
    on_failure = continue
    inline = [
      <<EOF
cat << EOT > ansible.cfg
[defaults]
retry_files_enabled = False
pipelining          = True
host_key_checking   = False
log_path            = /root/tang-remove-subscription-logs.txt
EOT

ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory remove-subscription.yml
EOF
    ]
  }
}

resource "null_resource" "tang_install" {
  count = 1

  depends_on = [
    null_resource.tang_setup
  ]

  triggers = {
    external_ip        = var.bastion_public_ip
    rhel_username      = var.rhel_username
    private_key        = local.private_key
    ssh_agent          = var.ssh_agent
    connection_timeout = "${var.connection_timeout}m"
  }

  connection {
    type        = "ssh"
    user        = self.triggers.rhel_username
    host        = self.triggers.external_ip
    private_key = self.triggers.private_key
    agent       = self.triggers.ssh_agent
    timeout     = self.triggers.connection_timeout
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      <<EOF
cat << EOT > ansible.cfg
[defaults]
retry_files_enabled = False
pipelining          = True
host_key_checking   = False
log_path            = /root/tang-server-logs.txt
EOT

# See tag at https://github.com/linux-system-roles/nbde_server/releases
ansible-galaxy install linux-system-roles.nbde_server,1.4.6
# Lock in the system_roles - https://galaxy.ansible.com/fedora/linux_system_roles
ansible-galaxy collection install fedora.linux_system_roles:==1.82.0
ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory tang.yml
EOF
    ]
  }
}

resource "null_resource" "tang_report_details" {
  count = 1

  depends_on = [
    null_resource.tang_install
  ]

  triggers = {
    external_ip        = var.bastion_public_ip
    rhel_username      = var.rhel_username
    private_key        = local.private_key
    ssh_agent          = var.ssh_agent
    connection_timeout = "${var.connection_timeout}m"
  }

  connection {
    type        = "ssh"
    user        = self.triggers.rhel_username
    host        = self.triggers.external_ip
    private_key = self.triggers.private_key
    agent       = self.triggers.ssh_agent
    timeout     = self.triggers.connection_timeout
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      <<EOF
echo "=All NBDE Server jwk keys="
find /root/nbde_server/keys/ -type f || true
EOF
    ]
  }
}

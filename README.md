# `powervm-tang-server-automation`

The [`powervm-tang-server-automation` project](https://github.com/IBM/powervm-tang-server-automation) provides Terraform based automation code to help with the deployment of [Network Bound Disk Encryption (NBDE)](https://github.com/linux-system-roles/nbde_server) on [IBM® Power Systems™ virtualization and cloud management](https://www.ibm.com/products/powervc).

The NBDE Server, also called the tang server, is deployed in a 3-node cluster with a single [bastion host](https://en.wikipedia.org/wiki/Bastion_host). The tang server socket listens on port 7500.

# Installation Quickstart

- [Installation Quickstart](#installation-quickstart)
    - [Download the Automation Code](#download-the-automation-code)
    - [Setup Terraform Variables](#setup-terraform-variables)
    - [Start Install](#start-install)
    - [Post Install](#post-install)
        - [Fetch Keys from Bastion Node](#fetch-keys-from-bastion-node)
        - [Destroy Tang Server](#destroy-tang-server)

## Download the Automation Code

You'll need to use git to clone the deployment code when working off the main branch

```
$ git clone https://github.com/ibm/powervm-tang-server-automation
$ cd powervm-tang-server-automation
```

## Setup Terraform Variables

Update following variables in the [var.tfvars](../var.tfvars) based on your environment.

```
### PowerVC Details
auth_url    = "<https://<HOSTNAME>:5000/v3/>"
user_name   = "<powervc-login-user-name>"
password    = "<powervc-login-user-password>"
tenant_name = "<tenant_name>"
domain_name = "Default"

# Workload
openstack_availability_zone = "<<Host Group from PowerVC>>"
network_name = "workload"

# Virtual Machines
bastion = {
  image_id      = "27ebd00f-cbec-4e27-993d-56e4bd441584"
  instance_type = "base-ocp-squad-tiny"
  count         = 1
}
tang = {
  image_id      = "27ebd00f-cbec-4e27-993d-56e4bd441584"
  instance_type = "base-ocp-squad-tiny"
  count         = 3
}
domain = "sslip.io"

rhel_username                   = "root"
public_key_file                 = "data/id_rsa.pub"
private_key_file                = "data/id_rsa"
rhel_subscription_username      = "" #Leave this as-is if using CentOS as bastion image
rhel_subscription_password      = "" #Leave this as-is if using CentOS as bastion image

connection_timeout = 45
```

Note: rhel_image_name should reference a PowerVM image for Red Hat Enterprise Linux 9.0 or Centos 9. 

## Start Install

Run the following commands from within the directory.

```
$ terraform init
$ terraform plan -var-file=var.tfvars
$ terraform apply -var-file=var.tfvars
```

You may also use `opentofu`.

Note: Terraform Version should be ~>1.4.0

Now wait for the installation to complete. It may take around 20 mins to complete provisioning.

On a successful installation of a cluster, the details will be printed as shown below.

```
bastion_public_ip = [
  "163.68.*.*",
]
```

These details can be retrieved anytime by running the following command from the root folder of the code

```
$ terraform output
```

In case of any errors, you'll have to re-apply.

## Post Install

### Fetch Keys from Bastion Node

Once the deployment is completed successfully, you can connect to bastion node and fetch keys for every tang server

```
$ cat /root/nbde_server/keys/*
```

### Destroy Tang Server

Destroy the Tang Server

```
$ terraform destroy -var-file var.tfvars
```

### Backup

Per [Red Hat](https://www.redhat.com/en/blog/advanced-automation-and-management-network-bound-disk-encryption-rhel-system-roles)'
s blog, we've added the `nbde_server_fetch_keys: yes` This downloads the keys to the 'bastion host' and customers are
expected to backup the keys using their operations processes.

### Re-keying all NBDE servers

1. Connect to your Bastion host
2. Run the playbook with the rotate keys variable

```terraform
sudo env ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    -i inventory tang.yml -e nbde_server_rotate_keys=yes
```

### Re-keying (Deleting) a single Tang server keys

1. Connect to your Bastion host

2. Copy the `inventory` to `inventory-del`

```cp inventory inventory-del```

3. Edit the `inventory-del` for the hosts you want to rekey

4. Run the playbook with the rotate keys variable

```terraform
sudo env ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    -i inventory tang.yml -e nbde_server_rotate_keys=yes
```

## Automation Host Prerequisites

The automation needs to run from a system with internet access. This could be your laptop or a VM with public internet
connectivity. This automation code have been tested on the following Operating Systems:

- Mac OSX (Darwin)
- Linux (x86_64/ppc64le)
- Windows 10

Follow the [guide](docs/automation_host_prereqs.md) to complete the prerequisites.

## PowerVM Prerequisites

Follow the [guide](docs/prereqs_powervm.md) to complete the PowerVM prerequisites.

## Make It Better

For bugs/enhancement requests etc. please open a GitHub [issue](https://github.com/ibm/powervm-tang-server-automation/issues)

## Contributing

Please see the [contributing doc](CONTRIBUTING.md) for more details.

PRs are most welcome !!

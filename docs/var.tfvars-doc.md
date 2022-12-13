## Introduction

This guide gives an overview of the various terraform variables that are used for the deployment.
The default values are set in [variables.tf](../variables.tf)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | ~> 1.48 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_openstack"></a> [openstack](#provider\_openstack) | 1.49.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/1_bastion/ | n/a |
| <a name="module_fips"></a> [fips](#module\_fips) | ./modules/3_fips | n/a |
| <a name="module_nbde"></a> [nbde](#module\_nbde) | ./modules/2_nbde | n/a |

## Resources

| Name | Type |
|------|------|
| [openstack_compute_keypair_v2.kp](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_keypair_v2) | resource |
| [random_id.label](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_repo_name"></a> [ansible\_repo\_name](#input\_ansible\_repo\_name) | The Ansible repository name | `string` | `"ansible-2.9-for-rhel-8-ppc64le-rpms"` | no |
| <a name="input_auth_url"></a> [auth\_url](#input\_auth\_url) | The endpoint URL used to connect to OpenStack/PowerVC | `string` | `"https://<HOSTNAME>:5000/v3/"` | no |
| <a name="input_bastion"></a> [bastion](#input\_bastion) | n/a | `map` | <pre>{<br>  "count": 1,<br>  "image_id": "daa5d3f4-ab66-4b2d-9f3d-77bd61774419",<br>  "instance_type": "ocp4-medium"<br>}</pre> | no |
| <a name="input_bastion_health_status"></a> [bastion\_health\_status](#input\_bastion\_health\_status) | Specify if bastion should poll for the Health Status to be OK or WARNING. Default is OK. | `string` | `"OK"` | no |
| <a name="input_bastion_public_ip"></a> [bastion\_public\_ip](#input\_bastion\_public\_ip) | The bastion\_public\_ip is the IP used to deploy the NBDE servers when the bastion.count = 0, and uses a pre-existing bastion host | `string` | `""` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | n/a | `string` | `""` | no |
| <a name="input_connection_timeout"></a> [connection\_timeout](#input\_connection\_timeout) | Timeout in minutes for SSH connections | `number` | `30` | no |
| <a name="input_dns_forwarders"></a> [dns\_forwarders](#input\_dns\_forwarders) | n/a | `string` | `"8.8.8.8; 8.8.4.4"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain name to use to setup the cluster. A DNS Forward Zone should be a registered in IBM Cloud if use\_ibm\_cloud\_services = true | `string` | `"ibm.com"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain to be used | `string` | `"Default"` | no |
| <a name="input_fips_compliant"></a> [fips\_compliant](#input\_fips\_compliant) | Set to true to enable usage of FIPS for the deployment. | `bool` | `false` | no |
| <a name="input_insecure"></a> [insecure](#input\_insecure) | n/a | `string` | `"true"` | no |
| <a name="input_keypair_name"></a> [keypair\_name](#input\_keypair\_name) | n/a | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `""` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the network to be used for deploy operations | `string` | `"my_network_tang"` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | Specify the name of the network adapter type to use for creating hosts | `string` | `"SEA"` | no |
| <a name="input_openstack_availability_zone"></a> [openstack\_availability\_zone](#input\_openstack\_availability\_zone) | The name of Availability Zone for deploy operation | `string` | `""` | no |
| <a name="input_password"></a> [password](#input\_password) | The password for the user | `string` | `"****"` | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | content of private ssh key | `string` | `""` | no |
| <a name="input_private_key_file"></a> [private\_key\_file](#input\_private\_key\_file) | Path to private key file | `string` | `"data/id_rsa"` | no |
| <a name="input_private_network_mtu"></a> [private\_network\_mtu](#input\_private\_network\_mtu) | MTU value for the private network interface on RHEL and RHCOS nodes | `number` | `1450` | no |
| <a name="input_proxy"></a> [proxy](#input\_proxy) | External Proxy server details in a map | `object({})` | `{}` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Public key | `string` | `""` | no |
| <a name="input_public_key_file"></a> [public\_key\_file](#input\_public\_key\_file) | Path to public key file | `string` | `"data/id_rsa.pub"` | no |
| <a name="input_rhel_image_name"></a> [rhel\_image\_name](#input\_rhel\_image\_name) | Name of the RHEL image that you want to use for the bastion node | `string` | `"rhel-8.6"` | no |
| <a name="input_rhel_smt"></a> [rhel\_smt](#input\_rhel\_smt) | SMT value to set on the bastion node. Eg: on,off,2,4,8 | `number` | `4` | no |
| <a name="input_rhel_subscription_activationkey"></a> [rhel\_subscription\_activationkey](#input\_rhel\_subscription\_activationkey) | n/a | `string` | `"The subscription key for activating rhel"` | no |
| <a name="input_rhel_subscription_org"></a> [rhel\_subscription\_org](#input\_rhel\_subscription\_org) | n/a | `string` | `""` | no |
| <a name="input_rhel_subscription_password"></a> [rhel\_subscription\_password](#input\_rhel\_subscription\_password) | n/a | `string` | `""` | no |
| <a name="input_rhel_subscription_username"></a> [rhel\_subscription\_username](#input\_rhel\_subscription\_username) | n/a | `string` | `""` | no |
| <a name="input_rhel_username"></a> [rhel\_username](#input\_rhel\_username) | n/a | `string` | `"root"` | no |
| <a name="input_scg_id"></a> [scg\_id](#input\_scg\_id) | The id of PowerVC Storage Connectivity Group to use for all nodes | `string` | `""` | no |
| <a name="input_setup_squid_proxy"></a> [setup\_squid\_proxy](#input\_setup\_squid\_proxy) | Flag to install and configure squid proxy server on bastion node | `bool` | `false` | no |
| <a name="input_sriov_capacity"></a> [sriov\_capacity](#input\_sriov\_capacity) | Specifies the SR-IOV LP capacity | `number` | `0.02` | no |
| <a name="input_sriov_vnic_failover_vfs"></a> [sriov\_vnic\_failover\_vfs](#input\_sriov\_vnic\_failover\_vfs) | Specifies the amount of VNIC failover virtual functions (max. is 6) | `number` | `1` | no |
| <a name="input_ssh_agent"></a> [ssh\_agent](#input\_ssh\_agent) | Enable or disable SSH Agent. Can correct some connectivity issues. Default: false | `bool` | `false` | no |
| <a name="input_tang"></a> [tang](#input\_tang) | n/a | `map` | <pre>{<br>  "count": 3,<br>  "image_id": "468863e6-4b33-4e8b-b2c5-c9ef9e6eedf4",<br>  "instance_type": "ocp4-medium"<br>}</pre> | no |
| <a name="input_tang_health_status"></a> [tang\_health\_status](#input\_tang\_health\_status) | n/a | `string` | `"WARNING"` | no |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | The name of the project (a.k.a. tenant) used | `string` | `"ibm-default"` | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | The user name used to connect to OpenStack/PowerVC | `string` | `"****"` | no |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | Must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character Length cannot exceed 14 characters when combined with cluster\_id\_prefix | `string` | `""` | no |
| <a name="input_vm_id_prefix"></a> [vm\_id\_prefix](#input\_vm\_id\_prefix) | Must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character Should not be more than 14 characters | `string` | `"infra-node"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
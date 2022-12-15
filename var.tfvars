### PowerVC Details
auth_url    = "<https://<HOSTNAME>:5000/v3/>"
user_name   = "<powervc-login-user-name>"
password    = "<powervc-login-user-password>"
tenant_name = "<tenant_name>"
domain_name = "Default"

# Workload
openstack_availability_zone = "<<Host Group from PowerVC>>"
network_name                = "workload"

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

rhel_username              = "root"
public_key_file            = "data/id_rsa.pub"
private_key_file           = "data/id_rsa"
rhel_subscription_username = "" #Leave this as-is if using CentOS as bastion image
rhel_subscription_password = "" #Leave this as-is if using CentOS as bastion image

connection_timeout = 45

# Prefix of the name
vm_id_prefix = "demo"

# Set it true if you prefer to use FIPS on each VM
#fips_compliant             = false
terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "2.6.0"
    }
    metal = {
      source  = "equinix/metal"
      version = "3.3.0"
    }
  }
}

provider "equinix" {
  client_id     = var.equinix_client_id
  client_secret = var.equinix_client_secret
}

provider "metal" {
  auth_token = var.auth_token
}

# Create VLANs in two metros with the same ID
resource "equinix_metal_vlan" "vlan1" {
  project_id = var.metal_project_id
  metro      = var.metro1
  vxlan      = var.vxlan
  description = "VLAN for Metro 1"
}

resource "equinix_metal_vlan" "vlan2" {
  project_id = var.metal_project_id
  metro      = var.metro2
  vxlan      = var.vxlan
  description = "VLAN for Metro 2"
}

# Provision Metal devices in different metros
resource "equinix_metal_device" "server1" {
  hostname         = "server1"
  plan             = var.plan
  metro            = var.metro1
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id
  user_data        = format("#!/bin/bash\napt update\napt install -y vlan\nmodprobe 8021q\nip link add link bond0 name bond0.%g type vlan id %g\nip addr add 192.168.100.1/24 brd 192.168.100.255 dev bond0.%g\nip link set dev bond0.%g up", var.vxlan, var.vxlan, var.vxlan, var.vxlan)
}

resource "equinix_metal_device" "server2" {
  hostname         = "server2"
  plan             = var.plan
  metro            = var.metro2
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id
  user_data        = format("#!/bin/bash\napt update\napt install -y vlan\nmodprobe 8021q\nip link add link bond0 name bond0.%g type vlan id %g\nip addr add 192.168.100.2/24 brd 192.168.100.255 dev bond0.%g\nip link set dev bond0.%g up", var.vxlan, var.vxlan, var.vxlan, var.vxlan)
}

# Attach VLANs to ports on devices
resource "equinix_metal_port_vlan_attachment" "server1_vlan" {
  device_id = equinix_metal_device.server1.id
  port_name = "bond0"
  vlan_vnid = equinix_metal_vlan.vlan1.vxlan
}

resource "equinix_metal_port_vlan_attachment" "server2_vlan" {
  device_id = equinix_metal_device.server2.id
  port_name = "bond0"
  vlan_vnid = equinix_metal_vlan.vlan2.vxlan
}
# Fabric Connection
resource "equinix_fabric_connection" "fabric_connection" {
  name      = "tf-metalport-fabric"
  type      = "EVPL_VC"
  bandwidth = 50

  notifications {
    type   = "ALL"
    emails = ["fsaleem@equinix.com"]
  }

  order {
    purchase_order_number = ""
  }

  a_side {
    access_point {
      type = "COLO"
      port {
        uuid = var.aside_port
      }
      link_protocol {
        type     = "DOT1Q"
        vlan_tag = equinix_metal_vlan.vlan1.vxlan
      }
      location {
        metro_code = var.metro1
      }
    }
  }

  z_side {
    service_token {
      uuid = equinix_metal_connection.example.service_tokens.0.id
    }
  }
}

# Metal Connection (Z-side)
resource "equinix_metal_connection" "example" {
  name               = "faizan-tf-metal-port"
  project_id         = var.metal_project_id
  type               = "shared"
  redundancy         = "primary"
  metro              = var.metro2
  speed              = "10Gbps"
  service_token_type = "z_side"
  contact_email      = "fsaleem@equinix.com"
  vlans              = [equinix_metal_vlan.vlan2.vxlan]
}

# Virtual Circuit
resource "equinix_metal_virtual_circuit" "vc" {
  connection_id = equinix_fabric_connection.fabric_connection.id
  project_id    = var.metal_project_id
  port_id       = var.aside_port
  vlan_id       = equinix_metal_vlan.vlan1.vxlan
  nni_vlan      = equinix_metal_vlan.vlan1.vxlan
  name          = "Fabric-Metal-VC"
}
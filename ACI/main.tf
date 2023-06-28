terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

#configure provider with your cisco aci credentials.
provider "aci" {
  # cisco-aci user name
  username = "admin"
  # cisco-aci password
  password = "C1sco12345"
  # cisco-aci url
  url      = "https://10.10.20.14"
  insecure = true
}


#########################
#Interface Policies#
#########################

# CDP
resource "aci_cdp_interface_policy" "cdp_enabled" {
  name        = "cdp_enabled"
  admin_st    = "enabled"
  annotation  = "tag_cdp"
  name_alias  = "alias_cdp"
  description = "From Terraform"
}

resource "aci_cdp_interface_policy" "cdp_disabled" {
  name        = "cdp_disabled"
  admin_st    = "disabled"
  annotation  = "tag_cdp"
  name_alias  = "alias_cdp"
  description = "From Terraform"
}


#Port Speeds
module "aci_link_level_policy" {
  source  = "netascode/link-level-policy/aci"
  version = ">= 0.1.0"

  name     = "10G"
  speed    = "10G"
  auto     = true
  fec_mode = "disable-fec"
}

module "aci_link_level_policy_example" {
  source  = "netascode/link-level-policy/aci"
  version = ">= 0.1.0"

  name     = "100G"
  speed    = "100G"
  auto     = true
  fec_mode = "disable-fec"
}


#Port Channels
module "aci_port_channel_policy_LACP_ACTIVE" {
  source  = "netascode/port-channel-policy/aci"
  version = ">= 0.1.0"

  name                 = "PC-LACP-ACTIVE"
  mode                 = "active"
  min_links            = 1
  max_links            = 16
  suspend_individual   = false
  graceful_convergence = false
  fast_select_standby  = false
  load_defer           = true
  symmetric_hash       = true
  hash_key             = "src-ip"
}

module "aci_port_channel_policy_MAC_PINNING" {
  source  = "netascode/port-channel-policy/aci"
  version = ">= 0.1.0"

  name                 = "PC-MAC_PINNING"
  mode                 = "mac-pin"
  min_links            = 1
  max_links            = 16
  suspend_individual   = false
  graceful_convergence = false
  fast_select_standby  = false
  load_defer           = true
  symmetric_hash       = true
  hash_key             = "src-ip"
}

module "aci_port_channel_policy_STATIC_ON" {
  source  = "netascode/port-channel-policy/aci"
  version = ">= 0.1.0"

  name                 = "PC-STATIC_ON"
  mode                 = "off"
  min_links            = 1
  max_links            = 16
  suspend_individual   = false
  graceful_convergence = false
  fast_select_standby  = false
  load_defer           = true
  symmetric_hash       = true
  hash_key             = "src-ip"
}

resource "aci_lldp_interface_policy" "LLDP_RX-on_TX-on" {
  description = "example description"
  name        = "LLDP_RX-on_TX-on"
  admin_rx_st = "enabled"
  admin_tx_st = "enabled"
  annotation  = "tag_lldp"
}
resource "aci_lldp_interface_policy" "LLDP_RX-off_TX-off" {
  description = "example description"
  name        = "LLDP_RX-off_TX-off"
  admin_rx_st = "disabled"
  admin_tx_st = "disabled"
  annotation  = "tag_lldp"
}
resource "aci_lldp_interface_policy" "LLDP_RX-on_TX-off" {
  description = "example description"
  name        = "LLDP_RX-on_TX-off"
  admin_rx_st = "enabled"
  admin_tx_st = "disabled"
  annotation  = "tag_lldp"
}
resource "aci_lldp_interface_policy" "LLDP_RX-off_TX-on" {
  description = "example description"
  name        = "LLDP_RX-off_TX-on"
  admin_rx_st = "disabled"
  admin_tx_st = "enabled"
  annotation  = "tag_lldp"
}


#MCP
module "aci_mcp_policy_off" {
  source  = "netascode/mcp-policy/aci"
  version = ">= 0.1.0"

  name        = "MCP-OFF"
  admin_state = false
}

module "aci_mcp_policy_on" {
  source  = "netascode/mcp-policy/aci"
  version = ">= 0.1.0"

  name        = "MCP-ON"
  admin_state = true
}


#########################
#Interface Policy Group#
#########################
module "aci_access_leaf_interface_policy_group" {
  source  = "netascode/access-leaf-interface-policy-group/aci"
  version = ">= 0.1.4"

  name              = "10G-CDP-LLDP"
  description       = "VPC Interface Policy Group 1"
  type              = "access"
  link_level_policy = "10G"
  cdp_policy        = "CDP-ON"
  lldp_policy       = "LLDP-ON"
  aaep              = "BU1_AAEP"
}

#########################
#Interface Profile#
#########################
resource "aci_leaf_interface_profile" "IntProf-101" {
  description = "From Terraform"
  name        = "IntProf-101"
  annotation  = "tag_leaf"
  name_alias  = "name_alias"
}

resource "aci_leaf_interface_profile" "IntProf-102" {
  description = "From Terraform"
  name        = "IntProf-102"
  annotation  = "tag_leaf"
  name_alias  = "name_alias"
}

#########################
#Interface Selector#
#########################
module "aci_access_leaf_interface_selector" {
  source  = "netascode/access-leaf-interface-selector/aci"
  version = ">= 0.2.0"

  interface_profile = "IntProf-101"
  name              = "E1"
  policy_group_type = "access"
  policy_group      = "10G-CDP-LLDP"
  port_blocks = [{
    name        = "PB1"
    description = "My Description"
    from_port   = 1
    to_port     = 1
  }]
}

module "aci_access_leaf_interface_selector_E2" {
  source  = "netascode/access-leaf-interface-selector/aci"
  version = ">= 0.2.0"

  interface_profile = "IntProf-101"
  name              = "E2"
  policy_group_type = "access"
  policy_group      = "10G-CDP-LLDP"
  port_blocks = [{
    name        = "PB2"
    description = "My Description"
    from_port   = 2
    to_port     = 2
  }]
}

module "aci_access_leaf_interface_selector_E3" {
  source  = "netascode/access-leaf-interface-selector/aci"
  version = ">= 0.2.0"

  interface_profile = "IntProf-101"
  name              = "E3"
  policy_group_type = "access"
  policy_group      = "10G-CDP-LLDP"
  port_blocks = [{
    name        = "PB3"
    description = "My Description"
    from_port   = 3
    to_port     = 3
  }]
}

module "aci_access_leaf_interface_selector_E4" {
  source  = "netascode/access-leaf-interface-selector/aci"
  version = ">= 0.2.0"

  interface_profile = "IntProf-101"
  name              = "E4"
  policy_group_type = "access"
  policy_group      = "10G-CDP-LLDP"
  port_blocks = [{
    name        = "PB4"
    description = "My Description"
    from_port   = 4
    to_port     = 4
  }]
}



#########################
#Switch Profile#
#########################
module "aci_access_leaf_switch_profile_profile_101" {
  source  = "netascode/access-leaf-switch-profile/aci"
  version = ">= 0.2.0"

  name               = "SW-PROFILE-101"
  interface_profiles = ["IntProf-101"]
  selectors = [{
    name = "LEAF101"
    # policy_group = "POL1"
    node_blocks = [{
      name = "LEAF101"
      from = 101
      to   = 101
    }]
  }]
}

module "aci_access_leaf_switch_profile_profile_102" {
  source  = "netascode/access-leaf-switch-profile/aci"
  version = ">= 0.2.0"

  name               = "SW-PROFILE-102"
  interface_profiles = ["IntProf-102"]
  selectors = [{
    name = "LEAF102"
    # policy_group = "POL1"
    node_blocks = [{
      name = "LEAF102"
      from = 102
      to   = 102
    }]
  }]
}

module "aci_access_leaf_switch_profile_profile_101-102" {
  source  = "netascode/access-leaf-switch-profile/aci"
  version = ">= 0.2.0"

  name = "SW-PROFILE-101-102"
  #   interface_profiles = ["IntProf-101-102"]
  selectors = [{
    name = "LEAF101-102"
    # policy_group = "POL1"
    node_blocks = [{
      name = "LEAF101-102"
      from = 101
      to   = 102
    }]
  }]
}

#########################
#VLAN Pool#
#########################
module "aci_vlan_pool_BU1_BMH-VLAN" {
  source  = "netascode/vlan-pool/aci"
  version = ">= 0.2.2"

  name        = "BU1_BMH-VLAN"
  description = "Vlan Pool 1"
  allocation  = "static"
  ranges = [{
    description = "Range 1"
    from        = 1000
    to          = 1000
    allocation  = "inherit"
    role        = "internal"
    },
    {
      description = "Range 2"
      from        = 1001
      to          = 1001
      allocation  = "inherit"
      role        = "internal"
  }]
}

module "aci_vlan_pool_BU1_VMM-VLAN" {
  source  = "netascode/vlan-pool/aci"
  version = ">= 0.2.2"

  name        = "BU1_VMM-VLAN"
  description = "Vlan Pool 2"
  allocation  = "dynamic"
  ranges = [{
    description = "Range 1"
    from        = 1005
    to          = 1020
    allocation  = "inherit"
    role        = "internal"
  }]
}


#########################
#Physical Domain#
#########################
module "aci_physical_domain_BU1_BMH-Domain" {
  source  = "netascode/physical-domain/aci"
  version = ">= 0.1.0"

  name                 = "BU1_BMH-Domain"
  vlan_pool            = "BU1_BMH-VLAN"
  vlan_pool_allocation = "static"
}

#########################
#AAEP#
#########################
module "aci_aaep" {
  source  = "netascode/aaep/aci"
  version = ">= 0.2.0"

  name = "BU1_AAEP"
  #   infra_vlan       = 10
  physical_domains = ["BU1_BMH-Domain"]
  #   routed_domains     = ["RD1"]
  #   vmware_vmm_domains = ["VMM1"]
  #   endpoint_groups = [{
  # tenant               = "BU1"
  # application_profile  = "BU1_AP1"
  # endpoint_group       = "BU1_EPG1"
  # primary_vlan         = 10
  # secondary_vlan       = 20
  # mode                 = "untagged"
  # deployment_immediacy = "immediate"
  #   }]
}
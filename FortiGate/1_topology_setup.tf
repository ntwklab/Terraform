terraform {
  required_providers {
    fortios = {
        source = "fortinetdev/fortios"
    }
  }
}

provider "fortios" {
  hostname = "10.10.30.215"
  token = "5qn3Gk0hH5fxpjN6jhsyzwrmwt0gyg"
  insecure = true
}



#Interfaces
resource "fortios_system_interface" "INSIDE" {
  algorithm    = "L4"
  defaultgw    = "enable"
  distance     = 5
  ip           = "192.168.10.1 255.255.255.0"
  mtu          = 1500
  mtu_override = "disable"
  name         = "port2"
  type         = "physical"
  vdom         = "root"
  mode         = "static"
  snmp_index   = 3
  description  = "Created by Terraform Provider for FortiOS"
  ipv6 {
    nd_mode = "basic"
  }
}

resource "fortios_system_interface" "DMZ" {
  algorithm    = "L4"
  defaultgw    = "enable"
  distance     = 5
  ip           = "192.168.20.1 255.255.255.0"
  mtu          = 1500
  mtu_override = "disable"
  name         = "port3"
  type         = "physical"
  vdom         = "root"
  mode         = "static"
  snmp_index   = 3
  description  = "Created by Terraform Provider for FortiOS"
  ipv6 {
    nd_mode = "basic"
  }
}


#DHCP
resource "fortios_systemdhcp_server" "INSIDE_DHCP" {
  dns_service = "default"
  fosid       = 1
  interface   = "port2"
  netmask     = "255.255.255.0"
  status      = "enable"
  # ntp_server1 = "192.168.52.22"
  # timezone    = "00"
  default_gateway = "192.168.10.1"

  ip_range {
    end_ip   = "192.168.10.200"
    id       = 1
    start_ip = "192.168.10.100"
  }
}

resource "fortios_systemdhcp_server" "DMZ_DHCP" {
  dns_service = "default"
  fosid       = 2
  interface   = "port3"
  netmask     = "255.255.255.0"
  status      = "enable"
  # ntp_server1 = "192.168.52.22"
  # timezone    = "00"
  default_gateway = "192.168.20.1"

  ip_range {
    end_ip   = "192.168.20.200"
    id       = 1
    start_ip = "192.168.20.100"
  }
}


#DNS
resource "fortios_system_dns" "trname" {
  cache_notfound_responses = "disable"
  dns_cache_limit          = 5000
  dns_cache_ttl            = 1800
  ip6_primary              = "::"
  ip6_secondary            = "::"
  primary                  = "1.1.1.1"
  retry                    = 2
  secondary                = "8.8.8.8"
  source_ip                = "0.0.0.0"
  timeout                  = 5
  domain {
    domain = "fortitest.lab"
  }
}


#Static Route to Internet
resource "fortios_router_static" "trname" {
  bfd                 = "disable"
  blackhole           = "disable"
  device              = "port1"
  distance            = 10
  dst                 = "0.0.0.0 0.0.0.0"
  dynamic_gateway     = "disable"
  gateway             = "10.10.30.1"
  internet_service    = 0
  link_monitor_exempt = "disable"
  priority            = 22
  seq_num             = 1
  src                 = "0.0.0.0 0.0.0.0"
  status              = "enable"
  virtual_wan_link    = "disable"
  vrf                 = 0
  weight              = 2
}


#PAT INSIDE
resource "fortios_firewall_policy" "PAT_INSIDE" {
  action             = "accept"
  logtraffic         = "utm"
  name               = "PAT_INSIDE"
  policyid           = 1
  schedule           = "always"
  wanopt             = "disable"
  wanopt_detection   = "active"
  wanopt_passive_opt = "default"
  wccp               = "disable"
  webcache           = "disable"
  webcache_https     = "disable"
  wsso               = "enable"
  nat                = "enable"

  dstaddr {
    name = "all"
  }

  dstintf {
    name = "port1"
  }
  service {
    name = "ALL"
  }

  srcaddr {
    name = "all"
  }

  srcintf {
    name = "port2"
  }
}


#Add addresses as objects
resource "fortios_firewall_address" "DMZ_Server" {
  allow_routing        = "disable"
  associated_interface = "port3"
  color                = 3
  end_ip               = "255.255.255.255"
  name                 = "DMZ_Server"
  start_ip             = "192.168.20.102"
  subnet               = "192.168.20.0 255.255.255.0"
  type                 = "ipmask"
  visibility           = "enable"
}

resource "fortios_firewall_address" "DMZ_Server_NAT" {
  allow_routing        = "disable"
  associated_interface = "port1"
  color                = 3
  end_ip               = "255.255.255.255"
  name                 = "DMZ_Server_NAT"
  start_ip             = "10.10.30.222"
  subnet               = "10.10.30.222 255.255.255.0"
  type                 = "ipmask"
  visibility           = "enable"
}


#DMZ NAT IP Proxy ARP
resource "fortios_system_proxyarp" "DMZ_Server_NAT" {
  end_ip    = "10.10.30.222"
  fosid     = 1
  interface = "port1"
  ip        = "10.10.30.222"
}


#NAT DMZ IN VIP
resource "fortios_firewall_vip" "DMZ_NAT_IN" {
  arp_reply                        = "enable"
  color                            = 0
  dns_mapping_ttl                  = 0
  extintf                          = "port1"
  extip                            = "10.10.30.222"
  extport                          = "0-65535"
  fosid                            = 0
  http_cookie_age                  = 60
  http_cookie_domain_from_host     = "disable"
  http_cookie_generation           = 0
  http_cookie_share                = "same-ip"
  http_ip_header                   = "disable"
  http_multiplex                   = "disable"
  https_cookie_secure              = "disable"
  ldb_method                       = "static"
  mappedport                       = "0-65535"
  max_embryonic_connections        = 1000
  name                             = "DMZ_NAT_IN"
  nat_source_vip                   = "enable"
  outlook_web_access               = "disable"
  persistence                      = "none"
  portforward                      = "disable"
  portmapping_type                 = "1-to-1"
  protocol                         = "tcp"
  type                             = "static-nat"
  mappedip {
    range = "192.168.20.102"
  }
}

#NAT DMZ IN firewall policy
resource "fortios_firewall_policy" "DMZ_NAT_IN" {
  action             = "accept"
  logtraffic         = "utm"
  name               = "DMZ_NAT_IN"
  policyid           = 3
  schedule           = "always"
  wanopt             = "disable"
  wanopt_detection   = "active"
  wanopt_passive_opt = "default"
  wccp               = "disable"
  webcache           = "disable"
  webcache_https     = "disable"
  wsso               = "enable"

  dstaddr {
    name = "DMZ_NAT_IN"
  }

  dstintf {
    name = "port3"
  }
  service {
    name = "ALL"
  }

  srcaddr {
    name = "all"
  }

  srcintf {
    name = "port1"
  }
}


#Firewall Rule INSIDE to DMZ
resource "fortios_firewall_policy" "INSIDE_DMZ" {
  action             = "accept"
  logtraffic         = "utm"
  name               = "INSIDE_DMZ"
  policyid           = 4
  schedule           = "always"
  wanopt             = "disable"
  wanopt_detection   = "active"
  wanopt_passive_opt = "default"
  wccp               = "disable"
  webcache           = "disable"
  webcache_https     = "disable"
  wsso               = "enable"

  dstaddr {
    name = "all"
  }

  dstintf {
    name = "port3"
  }
  service {
    name = "ALL"
  }

  srcaddr {
    name = "all"
  }

  srcintf {
    name = "port2"
  }
}

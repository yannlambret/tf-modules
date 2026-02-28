output "name" {
  description = "The name of the libvirt network."
  value       = var.network.name
}

output "bridge" {
  description = "The name of the Linux bridge interface backing this network."
  value       = libvirt_network.network.bridge.name
}

output "domain" {
  description = "The DNS search domain associated with the network."
  value       = var.network.domain
}

output "ipv4_cidr" {
  description = "The CIDR block of the IPv4 network."
  value       = var.network.ipv4_cidr
}

output "ipv6_cidr" {
  description = "The IPv6 CIDR block of the network, or null if IPv6 is not configured."
  value       = var.network.ipv6_cidr
}

output "gateway_ipv4_address" {
  description = "The IPv4 address of the gateway (first host in the CIDR block)."
  value       = local.gateway_ipv4_address
}

output "gateway_ipv6_address" {
  description = "The IPv6 address of the gateway (first host in the IPv6 CIDR block), or null if IPv6 is not configured."
  value       = local.gateway_ipv6_address
}

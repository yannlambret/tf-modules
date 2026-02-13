output "name" {
  description = "The name of the libvirt network."
  value       = var.network.name
}

output "bridge" {
  description = "The name of the Linux bridge interface backing this network."
  value       = libvirt_network.network.bridge.name
}

output "cidr" {
  description = "The CIDR block of the network."
  value       = var.network.cidr
}

output "gateway_ipv4_address" {
  description = "The IPv4 address of the gateway (first host in the CIDR block)."
  value       = local.gateway_ipv4_address
}

output "domain" {
  description = "The DNS search domain associated with the network."
  value       = var.network.domain
}

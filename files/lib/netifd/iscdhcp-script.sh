#!/bin/sh

. /lib/netifd/netifd-proto.sh

# Find logical interface name (PROTO_IFACE) from physical interface ($interface)
# $interface is provided by dhclient as an environment variable
PROTO_IFACE=$(ubus call network.interface dump | jsonfilter -e "@.interface[@.device='${interface}' && @.proto='iscdhcp'].interface" | awk '{print $1}')

if [ -z "$PROTO_IFACE" ]; then
    # Fallback: find any interface using iscdhcp protocol if device match fails
    PROTO_IFACE=$(ubus call network.interface dump | jsonfilter -e "@.interface[@.proto='iscdhcp'].interface" | awk '{print $1}')
fi

[ -z "$PROTO_IFACE" ] && exit 1
[ -z "$reason" ] && exit 1

case "$reason" in
	BOUND|RENEW|REBIND|REBOOT)
		proto_init_update "$interface" 1

		# IP and Subnet
		[ -n "$new_ip_address" ] && {
			proto_add_ipv4_address "$new_ip_address" "${new_subnet_mask:-24}"
		}

		# Default Route
		for router in $new_routers; do
			proto_add_ipv4_route 0.0.0.0 0 "$router"
		done

		# DNS Servers
		for dns in $new_domain_name_servers; do
			proto_add_dns_server "$dns"
		done

		# DNS Search
		for domain in $new_domain_name; do
			proto_add_dns_search "$domain"
		done

		# Use the logical interface name for the final notification
		proto_send_update "$PROTO_IFACE"
		;;
	EXPIRE|FAIL|RELEASE|STOP)
		proto_init_update "$interface" 0
		proto_send_update "$PROTO_IFACE"
		;;
esac

exit 0

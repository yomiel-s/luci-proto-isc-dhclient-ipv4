#!/bin/sh

. /lib/netifd/netifd-proto.sh
init_proto "$@"

proto_iscdhcp_init_config() {
	proto_config_add_string "hostname"
	proto_config_add_string "clientid"
	proto_config_add_string "vendorid"
	proto_config_add_boolean "broadcast"
	proto_config_add_string "reqopts"
	proto_config_add_string "request_ip"
	proto_config_add_string "sendopts"
}

proto_iscdhcp_setup() {
	local config="$1"
	local iface="$2"
	local hostname clientid vendorid broadcast reqopts request_ip sendopts

	json_get_vars hostname clientid vendorid broadcast reqopts request_ip sendopts

	local conf_file="/tmp/dhclient-$config.conf"
	local script_file="/lib/netifd/iscdhcp-script.sh"
	local pid_file="/var/run/dhclient-$config.pid"
	local lease_file="/var/lib/dhcp/dhclient-$config.leases"

	mkdir -p /var/lib/dhcp

	# Base Definitions
	echo "option rfc3442-classless-static-routes code 121 = array of unsigned integer 8;" > "$conf_file"
	echo "option ms-classless-static-routes code 249 = array of unsigned integer 8;" >> "$conf_file"
	echo "option wpad code 252 = string;" >> "$conf_file"

	# Advanced Config
	[ "$broadcast" = "1" ] && echo "always-broadcast on;" >> "$conf_file"
	[ -n "$request_ip" ] && echo "send dhcp-requested-address $request_ip;" >> "$conf_file"
	
	# Common Identifiers
	[ -n "$hostname" ] && echo "send host-name \"$hostname\";" >> "$conf_file"
	[ -n "$clientid" ] && echo "send dhcp-client-identifier $clientid;" >> "$conf_file"
	[ -n "$vendorid" ] && echo "send vendor-class-identifier \"$vendorid\";" >> "$conf_file"
	
	echo "send dhcp-max-message-size 1500;" >> "$conf_file"

	# Custom Parameter Request List (Option 55)
	if [ -n "$reqopts" ]; then
		# Replace spaces with commas if needed
		reqopts_commas=$(echo "$reqopts" | tr ' ' ',')
		echo "request $reqopts_commas;" >> "$conf_file"
	else
		# Default matched to dhcp-dump.txt
		echo "request subnet-mask, routers, domain-name-servers, domain-name," >> "$conf_file"
		echo "        router-discovery, static-routes, vendor-encapsulated-options," >> "$conf_file"
		echo "        netbios-name-servers, netbios-node-type, netbios-scope," >> "$conf_file"
		echo "        rfc3442-classless-static-routes, ms-classless-static-routes, wpad;" >> "$conf_file"
	fi

	# Raw Custom Send Options (Multiple lines supported if passed as string)
	if [ -n "$sendopts" ]; then
		echo "$sendopts" >> "$conf_file"
	fi

	proto_run_command "$config" /usr/sbin/dhclient -d -v \
		-cf "$conf_file" \
		-sf "$script_file" \
		-pf "$pid_file" \
		-lf "$lease_file" \
		"$iface"
}

proto_iscdhcp_teardown() {
	local config="$1"
	proto_kill_command "$config"
}

add_protocol iscdhcp

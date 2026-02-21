'use strict';
'require form';
'require network';

return network.registerProtocol('iscdhcp', {
	getI18n: function() {
		return _('ISC DHCP Client');
	},

	renderFormOptions: function(s) {
		var o;

		// Use existing tabs 'general' and 'advanced' provided by the interface section
		// Tab General
		o = s.taboption('general', form.Value, 'hostname', _('Hostname'), _('Custom hostname to send to the DHCP server'));
		o.placeholder = 'ExampleHost';
		o.rmempty = true;

		o = s.taboption('general', form.Value, 'clientid', _('Client ID'), _('Custom Client ID (e.g., 01:11:22:33:44:55:66)'));
		o.placeholder = '01:11:22:33:44:55:66';
		o.rmempty = true;

		o = s.taboption('general', form.Value, 'vendorid', _('Vendor Class ID'), _('Custom Vendor Class ID (e.g., MSFT 5.0)'));
		o.placeholder = 'MSFT 5.0';
		o.rmempty = true;

		// Tab Advanced
		o = s.taboption('advanced', form.Flag, 'broadcast', _('Always Broadcast'), _('Required for certain ISPs or servers'));
		o.default = o.disabled;

		o = s.taboption('advanced', form.Value, 'request_ip', _('Request IP Address'), _('Request a specific IP address (Option 50)'));
		o.datatype = 'ip4addr';
		o.rmempty = true;

		o = s.taboption('advanced', form.Value, 'reqopts', _('Custom Request Options'), _('Comma-separated list of DHCP option names or numbers (Option 55)'));
		o.placeholder = 'subnet-mask, routers, domain-name-servers, domain-name, ...';
		o.rmempty = true;

		o = s.taboption('advanced', form.TextValue, 'sendopts', _('Custom Send Options'), _('Raw configuration block for dhclient.conf (e.g., send dhcp-client-identifier ...;)'));
		o.rmempty = true;
		o.rows = 5;
	}
});

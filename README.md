# LuCI ISC-DHCP Protocol Plugin (luci-proto-isc-dhclient-ipv4)

![Build Status](https://github.com/yomiel-s/luci-proto-isc-dhclient-ipv4/actions/workflows/build.yml/badge.svg)

[中文文档](./README-CN.md)

An OpenWrt LuCI protocol plugin designed to replace the default `udhcpc` with `isc-dhclient` for obtaining interface IP addresses. 
It is particularly useful in environments with strict DHCP packet characteristic requirements, such as certain corporate networks or specific ISP admission requirements.

## Dependencies

*   **OpenWrt Version**: OpenWrt 21.02 or higher is recommended (requires LuCI Client-side Rendering / JavaScript API support).
*   **Required Packages**:
    *   `isc-dhcp-client-ipv4` (provides the `/usr/sbin/dhclient` binary)
    *   `luci-base`
    *   `luci-mod-network`
    *   `rpcd`

## Key Features

*   **Full LuCI Integration**: Complete all configurations through the Web interface without manually editing command-line scripts.
*   **Custom Identifiers**: Supports custom Hostname (Option 12), Client ID (Option 61), and Vendor Class ID (Option 60).
*   **Advanced Parameter Requests**: Supports customizing the order and content of Option 55 (Parameter Request List). The default configuration is preset to match standard Windows client characteristics.
*   **Broadcast Flag Support**: Can force the DHCP broadcast flag (Always Broadcast) to resolve issues where some gateways cannot handle unicast responses.
*   **Specific IP Request**: Supports requesting a specific IPv4 address via Option 50.
*   **Native Configuration Injection**: Provides a raw configuration block input field to inject any native configuration directives directly into `dhclient.conf`.

## File Structure

*   `Makefile`: OpenWrt package build script.
*   `files/lib/netifd/proto/iscdhcp.sh`: Netifd protocol integration script.
*   `files/lib/netifd/iscdhcp-script.sh`: `dhclient` event callback script for synchronizing network status.
*   `files/www/luci-static/resources/protocol/iscdhcp.js`: LuCI JavaScript protocol interface definition.
*   `files/usr/share/rpcd/acl.d/luci-proto-isc-dhclient-ipv4.json`: LuCI permission configuration file.

## Installation

### Option A: Download from GitHub Releases (Easiest)
Go to the [Releases](https://github.com/yomiel-s/luci-proto-isc-dhclient-ipv4/releases) page and download the pre-compiled `.ipk` file for your version. Upload it to your router and run:
```bash
opkg update
opkg install luci-proto-isc-dhclient-ipv4_*.ipk
```

### Option B: Compile from Source
1. Place this directory into the `package/` directory of your OpenWrt source tree.
2. Run `make menuconfig`.
3. Navigate to `LuCI -> 3. Protocols` and select `luci-proto-isc-dhclient-ipv4`.
4. Compile: `make package/luci-proto-isc-dhclient-ipv4/compile V=s`.
5. Upload the generated `.ipk` file to your router and install it using `opkg install`.

### Option C: Manual Deployment
You can just upload all files under `files/` to their corresponding paths on the router to complete the deployment process.

1. **Install Dependencies**:
   ```bash
   opkg update
   opkg install isc-dhcp-client-ipv4
   ```

2. **Upload and Set Permissions**:
   Copy the contents of the `files/` directory to the root directory `/` of the router.
   ```bash
   chmod +x /lib/netifd/proto/iscdhcp.sh
   chmod +x /lib/netifd/iscdhcp-script.sh
   ```

3. **Clear LuCI Cache**:
   ```bash
   rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
   /etc/init.d/rpcd restart
   ```

## Configuration Guide

1. Log in to the LuCI Web interface and go to **Network -> Interfaces**.
2. Edit the interface that needs to use this protocol, and select **ISC DHCP Client** from the **Protocol** drop-down menu.
3. In **General Settings**:
   *   Set `Hostname` (e.g., `ExampleHost`).
   *   Set `Client ID` (e.g., `01:11:22:33:44:55:66`).
   *   Set `Vendor Class ID` (e.g., `MSFT 5.0`).
4. In **Advanced Settings**:
   *   To force broadcast, check `Always Broadcast`.
   *   To request specific parameters, enter comma-separated option names in `Custom Request Options` (e.g., `subnet-mask, routers, ...`).
5. Click **Save & Apply**.

## License

[Apache-2.0](./LICENSE.md)

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-proto-isc-dhclient-ipv4
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=yomiel-s <alexander49538@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-proto-isc-dhclient-ipv4
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Protocols
  TITLE:=LuCI support for ISC DHCP Client
  DEPENDS:=+isc-dhcp-client-ipv4 +luci-base +luci-mod-network +rpcd
  PKGARCH:=all
endef

define Package/luci-proto-isc-dhclient-ipv4/description
  This package provides LuCI and Netifd integration for using isc-dhclient 
  to obtain DHCP addresses on OpenWrt interfaces, matching custom requirements.
endef

define Build/Compile
endef

define Package/luci-proto-isc-dhclient-ipv4/install
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/lib/netifd/proto/iscdhcp.sh $(1)/lib/netifd/proto/iscdhcp.sh
	
	$(INSTALL_DIR) $(1)/lib/netifd
	$(INSTALL_BIN) ./files/lib/netifd/iscdhcp-script.sh $(1)/lib/netifd/iscdhcp-script.sh

	$(INSTALL_DIR) $(1)/www/luci-static/resources/protocol
	$(INSTALL_DATA) ./files/www/luci-static/resources/protocol/iscdhcp.js $(1)/www/luci-static/resources/protocol/iscdhcp.js

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-proto-isc-dhclient-ipv4.json $(1)/usr/share/rpcd/acl.d/luci-proto-isc-dhclient-ipv4.json
endef

$(eval $(call BuildPackage,luci-proto-isc-dhclient-ipv4))

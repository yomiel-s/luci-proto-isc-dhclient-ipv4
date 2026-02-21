# LuCI ISC-DHCP 协议插件 (luci-proto-isc-dhclient-ipv4)

![Build Status](https://github.com/yomiel-s/luci-proto-isc-dhclient-ipv4/actions/workflows/build.yml/badge.svg)

[English](./README.md)

一个OpenWrt 的 LuCI 协议插件，旨在通过 `isc-dhclient` 替代默认的 `udhcpc` 来获取接口 IP。
它特别适用于对 DHCP 报文特征有严格要求的环境（如某些企业内网或特定的 ISP 准入要求）。

## 环境依赖

*   **OpenWrt 版本**：建议 OpenWrt 21.02 及以上版本（需支持 LuCI Client-side Rendering / JavaScript API）。
*   **依赖软件包**：
    *   `isc-dhcp-client-ipv4` (提供 `/usr/sbin/dhclient` 二进制文件)
    *   `luci-base`
    *   `luci-mod-network`
    *   `rpcd`

## 主要功能

*   **完全集成 LuCI**：在 Web 界面即可完成所有配置，无需手动编辑命令行脚本。
*   **标识符自定义**：支持自定义 Hostname (Option 12)、Client ID (Option 61) 和 Vendor Class ID (Option 60)。
*   **高级参数请求**：支持自定义 Option 55 (Parameter Request List) 的顺序和内容，默认配置已预设为匹配标准 Windows 客户端特征。
*   **广播标志支持**：可强制开启 DHCP 广播标志（Always Broadcast），解决某些网关无法处理单播响应的问题。
*   **特定 IP 请求**：支持通过 Option 50 请求分配特定的 IPv4 地址。
*   **原生配置注入**：提供原始配置块输入框，支持直接向 `dhclient.conf` 注入任何原生配置指令。

## 文件结构

*   `Makefile`: OpenWrt 软件包构建脚本。
*   `files/lib/netifd/proto/iscdhcp.sh`: Netifd 协议集成脚本。
*   `files/lib/netifd/iscdhcp-script.sh`: `dhclient` 事件回调处理脚本，用于同步网络状态。
*   `files/www/luci-static/resources/protocol/iscdhcp.js`: LuCI JavaScript 协议界面定义。
*   `files/usr/share/rpcd/acl.d/luci-proto-isc-dhclient-ipv4.json`: LuCI 权限配置文件。

## 安装方法

### 方案 A：从 GitHub Releases 下载 (最便捷)
前往 [Releases](https://github.com/yomiel-s/luci-proto-isc-dhclient-ipv4/releases) 页面，下载对应版本的 `.ipk` 文件。然后将文件上传到路由器，并运行：
```bash
opkg update
opkg install luci-proto-isc-dhclient-ipv4_*.ipk
```

### 方案 B：从源码编译
1. 将此目录放入 OpenWrt 源码树的 `package/` 目录下。
2. 运行 `make menuconfig`。
3. 进入 `LuCI -> 3. Protocols` 勾选 `luci-proto-isc-dhclient-ipv4`。
4. 编译：`make package/luci-proto-isc-dhclient-ipv4/compile V=s`。
5. 将生成的 `.ipk` 文件上传到路由器并使用 `opkg install` 安装。

### 方案 C：手动部署
可直接将 `files/` 下的所有文件按其对应路径上传到路由器完成部署。

1. **安装依赖**：
   ```bash
   opkg update
   opkg install isc-dhcp-client-ipv4
   ```

2. **上传并设置权限**：
   将 `files/` 目录下的内容拷贝到路由器的根目录 `/`。
   ```bash
   chmod +x /lib/netifd/proto/iscdhcp.sh
   chmod +x /lib/netifd/iscdhcp-script.sh
   ```

3. **清理 LuCI 缓存**：
   ```bash
   rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
   /etc/init.d/rpcd restart
   ```

## 配置指南

1. 登录 LuCI Web 界面，进入 **网络 (Network) -> 接口 (Interfaces)**。
2. 编辑需要使用该协议的接口，在 **协议 (Protocol)** 下拉菜单中选择 **ISC DHCP Client**。
3. 在 **常规设置 (General Settings)** 中：
   *   设置 `Hostname`（例如：`ExampleHost`）。
   *   设置 `Client ID`（例如：`01:11:22:33:44:55:66`）。
   *   设置 `Vendor Class ID`（例如：`MSFT 5.0`）。
4. 在 **高级设置 (Advanced Settings)** 中：
   *   如需强制广播，勾选 `Always Broadcast`。
   *   如需请求特定参数，在 `Custom Request Options` 填入以逗号分隔的选项名（如 `subnet-mask, routers, ...`）。
5. 点击 **保存并应用 (Save & Apply)**。

## 许可证

[Apache-2.0](./LICENSE.md)

#!/bin/bash
# luci-app-upnp 有效时间功能部署脚本
# 用法: bash deploy.sh [源码目录]

set -e

OPENWRT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 部署 UPnP 有效时间功能 ==="
echo "目标目录: $OPENWRT_DIR"

# 检查目录
if [ ! -d "$OPENWRT_DIR/feeds/luci/applications/luci-app-upnp" ]; then
    echo "错误: 找不到 OpenWrt 源码目录"
    echo "用法: bash deploy.sh /path/to/openwrt"
    exit 1
fi

# 复制文件
echo "复制文件..."
cp -f "$SCRIPT_DIR/luci-app-upnp/htdocs/luci-static/resources/view/upnp/upnp.js" \
      "$OPENWRT_DIR/feeds/luci/applications/luci-app-upnp/htdocs/luci-static/resources/view/upnp/"

cp -f "$SCRIPT_DIR/luci-app-upnp/po/zh_Hans/upnp.po" \
      "$OPENWRT_DIR/feeds/luci/applications/luci-app-upnp/po/zh_Hans/"

cp -f "$SCRIPT_DIR/miniupnpd/files/miniupnpd.init" \
      "$OPENWRT_DIR/feeds/packages/net/miniupnpd/files/"

cp -f "$SCRIPT_DIR/miniupnpd/files/upnpd.config" \
      "$OPENWRT_DIR/feeds/packages/net/miniupnpd/files/"

echo "=== 部署完成 ==="
echo ""
echo "现在可以编译了:"
echo "  cd $OPENWRT_DIR"
echo "  make package/feeds/luci/luci-app-upnp/compile V=s"

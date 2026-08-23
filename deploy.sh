#!/bin/bash
# UPnP 有效时间功能部署脚本

set -e

OPENWRT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 部署 UPnP 有效时间功能 ==="

# 检查目录
if [ ! -d "$OPENWRT_DIR/feeds/packages/net" ]; then
    echo "错误: 找不到 OpenWrt 源码目录"
    echo "用法: bash deploy.sh /path/to/openwrt"
    exit 1
fi

# 1. 删除原来的包
echo "1. 删除原来的包..."
rm -rf "$OPENWRT_DIR/feeds/luci/applications/luci-app-upnp"
rm -rf "$OPENWRT_DIR/feeds/packages/net/miniupnpd"

# 2. 复制新的包
echo "2. 复制新的包..."
cp -r "$SCRIPT_DIR/luci-app-upnp" "$OPENWRT_DIR/feeds/luci/applications/"
cp -r "$SCRIPT_DIR/miniupnpd" "$OPENWRT_DIR/feeds/packages/net/"

echo ""
echo "=== 部署完成 ==="
echo ""
echo "现在可以编译了:"
echo "  cd $OPENWRT_DIR"
echo "  ./scripts/feeds update -a"
echo "  ./scripts/feeds install -a"
echo "  make package/feeds/packages/miniupnpd/compile V=s"

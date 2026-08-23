#!/bin/bash
# UPnP 有效时间功能部署脚本

set -e

OPENWRT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 部署 UPnP 有效时间功能 ==="

# 检查目录
if [ ! -d "$OPENWRT_DIR/feeds/packages/net/miniupnpd" ]; then
    echo "错误: 找不到 OpenWrt 源码目录"
    echo "用法: bash deploy.sh /path/to/openwrt"
    exit 1
fi

MINIUPNPD_DIR="$OPENWRT_DIR/feeds/packages/net/miniupnpd"

# 1. 复制 luci-app-upnp
echo "1. 复制 luci-app-upnp..."
cp -rf "$SCRIPT_DIR/luci-app-upnp" "$OPENWRT_DIR/feeds/luci/applications/"

# 2. 备份原始 miniupnpd
echo "2. 备份原始 miniupnpd..."
if [ -d "$MINIUPNPD_DIR/files" ]; then
    cp -rf "$MINIUPNPD_DIR/files" "$MINIUPNPD_DIR/files.bak"
fi

# 3. 复制 miniupnpd 配置文件
echo "3. 复制 miniupnpd 配置文件..."
cp -f "$SCRIPT_DIR/miniupnpd/files/miniupnpd.init" "$MINIUPNPD_DIR/files/"
cp -f "$SCRIPT_DIR/miniupnpd/files/upnpd.config" "$MINIUPNPD_DIR/files/"

# 4. 修改 Makefile 指向 GitHub
echo "4. 修改 Makefile..."
cd "$MINIUPNPD_DIR"
if [ -f Makefile ]; then
    # 备份
    cp Makefile Makefile.bak
    
    # 修改下载源
    sed -i 's|PKG_SOURCE_URL:=https://github.com/miniupnp/miniupnp/releases/download/miniupnpd_.*|PKG_SOURCE_URL:=https://github.com/hxlls/miniupnpd-igd-max-lifetime.git|' Makefile
    
    # 添加 git 协议支持（如果不存在）
    if ! grep -q "PKG_SOURCE_PROTO" Makefile; then
        sed -i '/PKG_SOURCE_URL:=https:\/\/github.com\/hxlls\/miniupnpd-igd-max-lifetime.git/a\PKG_SOURCE_PROTO:=git\nPKG_SOURCE_VERSION:=master' Makefile
    fi
    
    # 删除不需要的行
    sed -i '/PKG_SOURCE:=.*tar.gz/d' Makefile
    sed -i '/PKG_HASH:=/d' Makefile
fi

# 5. 删除补丁目录
echo "5. 删除补丁目录..."
rm -rf "$MINIUPNPD_DIR/patches"

echo ""
echo "=== 部署完成 ==="
echo ""
echo "现在可以编译了:"
echo "  cd $OPENWRT_DIR"
echo "  ./scripts/feeds update -a"
echo "  ./scripts/feeds install -a"
echo "  make package/feeds/packages/miniupnpd/compile V=s"

#!/bin/bash
# luci-app-upnp 有效时间功能部署脚本

set -e

OPENWRT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 部署 UPnP 有效时间功能 ==="
echo "目标目录: $OPENWRT_DIR"

# 检查目录
if [ ! -d "$OPENWRT_DIR/feeds/packages/net/miniupnpd" ]; then
    echo "错误: 找不到 OpenWrt 源码目录"
    echo "用法: bash deploy.sh /path/to/openwrt"
    exit 1
fi

MINIUPNPD_DIR="$OPENWRT_DIR/feeds/packages/net/miniupnpd"

# 复制 luci-app-upnp
echo "复制 luci-app-upnp..."
cp -rf "$SCRIPT_DIR/luci-app-upnp" "$OPENWRT_DIR/feeds/luci/applications/"

# 复制 miniupnpd 配置文件
echo "复制 miniupnpd 配置文件..."
cp -f "$SCRIPT_DIR/miniupnpd/files/miniupnpd.init" "$MINIUPNPD_DIR/files/"
cp -f "$SCRIPT_DIR/miniupnpd/files/upnpd.config" "$MINIUPNPD_DIR/files/"

# 创建补丁文件
echo "创建补丁文件..."
mkdir -p "$MINIUPNPD_DIR/patches"

# 生成补丁
cd "$SCRIPT_DIR/miniupnpd/src"
diff -u /dev/null options.h | sed 's|/dev/null|a/options.h|;s|/dev/null|b/options.h|' > /dev/null 2>&1 || true

# 直接复制源码文件作为参考（不推荐）
echo "注意: 需要手动修改 miniupnpd 源码"
echo "参考文件位置: $SCRIPT_DIR/miniupnpd/src/"
echo ""
echo "需要修改的文件:"
echo "  - options.h: 添加 UPNPUPNPMAXLIFETIME 枚举"
echo "  - options.c: 添加 upnp_max_lifetime 配置解析"
echo "  - upnpglobalvars.h: 添加 upnp_max_lifetime 声明"
echo "  - upnpglobalvars.c: 添加 upnp_max_lifetime 定义"
echo "  - miniupnpd.c: 添加配置解析逻辑"
echo "  - upnpsoap.c: 修改有效时间限制"
echo ""
echo "=== 部署完成 ==="

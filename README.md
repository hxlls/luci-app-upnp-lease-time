# luci-app-upnp 有效时间功能

为 OpenWrt/ImmortalWrt 的 luci-app-upnp 添加手动输入有效时间功能。

## 快速安装

```bash
# 1. 克隆本仓库
git clone https://github.com/hxlls/luci-app-upnp-lease-time.git

# 2. 复制 LuCI 应用
cp -r luci-app-upnp-lease-time/luci-app-upnp /path/to/openwrt/feeds/luci/applications/

# 3. 复制配置文件
cp luci-app-upnp-lease-time/miniupnpd-files/* /path/to/openwrt/feeds/packages/net/miniupnpd/files/

# 4. 修改 miniupnpd 下载地址
# 编辑 /path/to/openwrt/feeds/packages/net/miniupnpd/Makefile
# 修改 PKG_SOURCE_URL 为：
# PKG_SOURCE_URL:=https://github.com/hxlls/miniupnpd-igd-max-lifetime.git
# PKG_SOURCE_PROTO:=git
# PKG_SOURCE_VERSION:=master
# 删除 PKG_SOURCE 和 PKG_HASH 行

# 5. 删除补丁目录
rm -rf /path/to/openwrt/feeds/packages/net/miniupnpd/patches

# 6. 更新并编译
cd /path/to/openwrt
./scripts/feeds update -a
./scripts/feeds install -a
make package/feeds/packages/miniupnpd/compile V=s
```

## 功能

- **UPnP IGD 最大有效时间**: 限制 UPnP IGD 端口映射的最大有效时间（120-604800秒）
- **PCP 最大有效时间**: 限制 PCP 端口映射的最大有效时间（120-604800秒）

## 使用方法

### LuCI 界面

1. 进入 **服务 → UPnP IGD 和 PCP**
2. 点击 **高级设置**
3. 设置 **UPnP IGD 最大有效时间**（例如 3600 = 1小时）
4. 保存并应用

### 命令行

```bash
uci set upnpd.config.upnp_max_lifetime=3600
uci commit upnpd
/etc/init.d/miniupnpd restart
```

## 相关仓库

| 仓库 | 说明 |
|------|------|
| [luci-app-upnp-lease-time](https://github.com/hxlls/luci-app-upnp-lease-time) | 本仓库（LuCI 应用） |
| [miniupnpd-igd-max-lifetime](https://github.com/hxlls/miniupnpd-igd-max-lifetime) | 修改后的 miniupnpd 源码 |

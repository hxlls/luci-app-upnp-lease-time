# luci-app-upnp 有效时间功能

为 OpenWrt/ImmortalWrt 的 luci-app-upnp 添加手动输入有效时间功能。

## 功能

- **UPnP IGD 最大有效时间 (upnp_max_lifetime)**: 限制 UPnP IGD 端口映射的最大有效时间（120-604800秒）
- **PCP 最大有效时间 (max_lifetime)**: 限制 PCP 端口映射的最大有效时间（120-604800秒）
- **清理间隔 (clean_ruleset_interval)**: 检查和清理过期规则的时间间隔（秒）

## 安装方法

### 1. 修改 miniupnpd 下载源

编辑 `feeds.conf.default`，添加：

```
src-git-miniupnpd https://github.com/hxlls/miniupnpd-igd-max-lifetime.git
```

或者修改 `feeds/packages/net/miniupnpd/Makefile`：

```makefile
# 原始
PKG_SOURCE_URL:=https://github.com/miniupnp/miniupnp/releases/download/miniupnpd_$(subst .,_,$(PKG_VERSION))

# 修改为
PKG_SOURCE_URL:=https://github.com/hxlls/miniupnpd-igd-max-lifetime.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=master
```

### 2. 复制 luci-app-upnp

```bash
git clone https://github.com/hxlls/luci-app-upnp-lease-time.git
cd luci-app-upnp-lease-time
cp -r luci-app-upnp /path/to/openwrt/feeds/luci/applications/
cp miniupnpd/files/* /path/to/openwrt/feeds/packages/net/miniupnpd/files/
```

### 3. 更新 feeds 并编译

```bash
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig  # 选择 miniupnpd
make package/feeds/packages/miniupnpd/compile V=s
```

## 使用方法

### LuCI 界面设置

1. 在 LuCI 中进入 **服务 → UPnP IGD 和 PCP**
2. 点击 **高级设置** 标签
3. 设置 **UPnP IGD 最大有效时间**（例如 3600 = 1小时）
4. 保存并应用

### 命令行设置

```bash
# 设置 UPnP IGD 最大有效时间为 1 小时
uci set upnpd.config.upnp_max_lifetime=3600
uci commit upnpd

# 重启服务
/etc/init.d/miniupnpd restart
```

## 验证方法

```bash
# 检查配置文件
cat /var/etc/miniupnpd.conf | grep upnp_max_lifetime

# 查看当前 UPnP 规则
ubus call luci.upnp get_status
```

## 相关仓库

| 仓库 | 说明 |
|------|------|
| [luci-app-upnp-lease-time](https://github.com/hxlls/luci-app-upnp-lease-time) | LuCI 应用和配置文件 |
| [miniupnpd-igd-max-lifetime](https://github.com/hxlls/miniupnpd-igd-max-lifetime) | 修改后的 miniupnpd 源码 |

## 基于

- OpenWrt master
- ImmortalWrt master
- miniupnpd 2.3.9

## 许可证

- miniupnpd: BSD-3-Clause
- luci-app-upnp: Apache-2.0

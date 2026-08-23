# luci-app-upnp 有效时间功能

为 OpenWrt/ImmortalWrt 的 luci-app-upnp 添加手动输入有效时间功能。

## 快速安装

```bash
# 1. 克隆本仓库
git clone https://github.com/hxlls/luci-app-upnp-lease-time.git

# 2. 更新 feeds（下载原始包）
cd /path/to/openwrt
./scripts/feeds update -a

# 3. 替换为修改后的包
cd /path/to/luci-app-upnp-lease-time
bash deploy.sh /path/to/openwrt

# 4. 安装 feeds
cd /path/to/openwrt
./scripts/feeds install -a

# 5. 编译
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
| [luci-app-upnp-lease-time](https://github.com/hxlls/luci-app-upnp-lease-time) | 本仓库（包含所有内容） |
| [miniupnpd-igd-max-lifetime](https://github.com/hxlls/miniupnpd-igd-max-lifetime) | 修改后的 miniupnpd 源码 |

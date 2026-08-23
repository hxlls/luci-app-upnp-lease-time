# luci-app-upnp 有效时间功能

为 OpenWrt/ImmortalWrt 的 luci-app-upnp 添加手动输入有效时间功能。

## 快速安装

```bash
# 1. 克隆本仓库
git clone https://github.com/hxlls/luci-app-upnp-lease-time.git

# 2. 一键部署
cd luci-app-upnp-lease-time
bash deploy.sh /path/to/openwrt

# 3. 编译
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

## 仓库结构

```
luci-app-upnp-lease-time/
├── luci-app-upnp/      # LuCI 应用
├── miniupnpd/          # OpenWrt miniupnpd 包（已修改）
│   ├── Makefile        # 指向 GitHub 下载修改后的源码
│   └── files/          # 配置文件
├── deploy.sh           # 部署脚本
└── README.md
```

## 相关仓库

| 仓库 | 说明 |
|------|------|
| [luci-app-upnp-lease-time](https://github.com/hxlls/luci-app-upnp-lease-time) | 本仓库（包含所有内容） |
| [miniupnpd-igd-max-lifetime](https://github.com/hxlls/miniupnpd-igd-max-lifetime) | 修改后的 miniupnpd 源码 |

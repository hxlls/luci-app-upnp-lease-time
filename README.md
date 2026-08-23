# luci-app-upnp 有效时间功能

为 OpenWrt/ImmortalWrt 的 luci-app-upnp 添加手动输入有效时间功能。

## 功能

- **UPnP IGD 最大有效时间 (upnp_max_lifetime)**: 限制 UPnP IGD 端口映射的最大有效时间（120-604800秒）
- **PCP 最大有效时间 (max_lifetime)**: 限制 PCP 端口映射的最大有效时间（120-604800秒）
- **清理间隔 (clean_ruleset_interval)**: 检查和清理过期规则的时间间隔（秒）

## 目录结构

```
├── luci-app-upnp/          # LuCI 应用（完整）
│   ├── htdocs/             # 前端界面
│   ├── po/                 # 翻译文件
│   └── root/               # 配置和菜单
└── miniupnpd/
    ├── files/              # miniupnpd 服务文件
    │   ├── miniupnpd.init  # 启动脚本
    │   └── upnpd.config    # 默认配置
    └── patches/            # 源码补丁
        └── 050-add-igd-max-lifetime.patch
```

## 安装方法

### 方法1：使用部署脚本

```bash
git clone https://github.com/hxlls/luci-app-upnp-lease-time.git
cd luci-app-upnp-lease-time
bash deploy.sh /path/to/openwrt
```

### 方法2：手动复制

```bash
# 复制 luci-app-upnp
cp -r luci-app-upnp /path/to/openwrt/feeds/luci/applications/

# 复制 miniupnpd 文件
cp -r miniupnpd/files/* /path/to/openwrt/feeds/packages/net/miniupnpd/files/
cp miniupnpd/patches/* /path/to/openwrt/feeds/packages/net/miniupnpd/patches/

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a
```

## 使用方法

1. 在 LuCI 中进入 **服务 → UPnP IGD 和 PCP**
2. 点击 **高级设置** 标签
3. 设置 **UPnP IGD 最大有效时间**（例如 3600 = 1小时）
4. 设置 **PCP 最大有效时间**（例如 604800 = 168小时）
5. 设置 **清理间隔**（例如 600 = 10分钟）
6. 保存并应用

## 配置示例

```
config upnpd 'config'
    option enabled '1'
    option upnp_max_lifetime '3600'     # UPnP IGD 最大1小时
    option max_lifetime '604800'        # PCP 最大168小时
    option clean_ruleset_interval '600' # 10分钟清理一次
```

## 工作原理

1. 修改 miniupnpd 源码，添加 `upnp_max_lifetime` 配置选项
2. 在 `upnpsoap.c` 中限制 UPnP IGD 的有效时间
3. 客户端请求的超过限制的时间会被强制限制

## 基于

- OpenWrt master
- ImmortalWrt master
- miniupnpd 2.3.9

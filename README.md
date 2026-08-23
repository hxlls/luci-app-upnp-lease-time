# luci-app-upnp 有效时间功能

为 OpenWrt/ImmortalWrt 的 luci-app-upnp 添加手动输入有效时间功能。

## 功能

- **默认有效时间 (max_lifetime)**: 端口映射的默认有效时间，单位为秒（0 = 无限制）
- **清理间隔 (clean_ruleset_interval)**: 检查和清理过期规则的时间间隔（秒）

## 目录结构

```
├── luci-app-upnp/          # LuCI 应用（完整）
│   ├── htdocs/             # 前端界面
│   ├── po/                 # 翻译文件
│   └── root/               # 配置和菜单
└── miniupnpd/
    └── files/              # miniupnpd 服务文件
        ├── miniupnpd.init  # 启动脚本
        └── upnpd.config    # 默认配置
```

## 安装方法

### 方法1：复制到源码

```bash
# 复制 luci-app-upnp
cp -r luci-app-upnp /path/to/openwrt/feeds/luci/applications/

# 复制 miniupnpd 配置
cp miniupnpd/files/* /path/to/openwrt/feeds/packages/net/miniupnpd/files/

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a
```

### 方法2：作为 feed 添加

在 `feeds.conf.default` 中添加：

```
src-git upnp-custom https://github.com/hxlls/luci-app-upnp-lease-time.git
```

## 使用方法

1. 在 LuCI 中进入 **服务 → UPnP IGD 和 PCP**
2. 点击 **高级设置** 标签
3. 设置 **默认有效时间**（例如 3600 = 1小时）
4. 设置 **清理间隔**（例如 600 = 10分钟）
5. 保存并应用

## 配置示例

```
config upnpd 'config'
    option enabled '1'
    option max_lifetime '3600'          # 1小时
    option clean_ruleset_interval '600' # 10分钟清理一次
```

## 基于

- OpenWrt master
- ImmortalWrt master
- miniupnpd 2.3.x

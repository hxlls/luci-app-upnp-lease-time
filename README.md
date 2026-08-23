# luci-app-upnp 有效时间功能

为 OpenWrt/ImmortalWrt 的 luci-app-upnp 添加手动输入有效时间功能。

## 功能

- **UPnP IGD 最大有效时间 (upnp_max_lifetime)**: 限制 UPnP IGD 端口映射的最大有效时间（120-604800秒）
- **PCP 最大有效时间 (max_lifetime)**: 限制 PCP 端口映射的最大有效时间（120-604800秒）
- **清理间隔 (clean_ruleset_interval)**: 检查和清理过期规则的时间间隔（秒）

## 为什么需要这个功能？

默认情况下，miniupnpd 的 UPnP IGD 端口映射有效时间是 **168小时（7天）**，由客户端决定，服务器端无法控制。

这个补丁修改了 miniupnpd 源码，允许用户通过 LuCI 界面设置 UPnP IGD 的最大有效时间。

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

### 方法1：使用部署脚本（推荐）

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

### 方法3：作为 feed 添加（不推荐）

在 `feeds.conf.default` 中添加：

```
src-git upnp https://github.com/hxlls/luci-app-upnp-lease-time.git
```

**注意**：此方法可能导致编译错误，建议使用方法1或方法2。

## 使用方法

### LuCI 界面设置

1. 在 LuCI 中进入 **服务 → UPnP IGD 和 PCP**
2. 点击 **高级设置** 标签
3. 设置 **UPnP IGD 最大有效时间**（例如 3600 = 1小时）
4. 设置 **PCP 最大有效时间**（例如 604800 = 168小时）
5. 设置 **清理间隔**（例如 600 = 10分钟）
6. 保存并应用

### 命令行设置

```bash
# 设置 UPnP IGD 最大有效时间为 1 小时
uci set upnpd.config.upnp_max_lifetime=3600
uci commit upnpd

# 重启服务
/etc/init.d/miniupnpd restart
```

## 配置示例

```
config upnpd 'config'
    option enabled '1'
    option enable_natpmp '1'
    option enable_upnp '1'
    option secure_mode '1'
    option upnp_max_lifetime '3600'     # UPnP IGD 最大1小时
    option max_lifetime '604800'        # PCP 最大168小时
    option clean_ruleset_interval '600' # 10分钟清理一次
```

## 工作原理

1. 修改 miniupnpd 源码，添加 `upnp_max_lifetime` 配置选项
2. 在 `upnpsoap.c` 中限制 UPnP IGD 的有效时间
3. 客户端请求的超过限制的时间会被强制限制

### 修改的源码文件

| 文件 | 修改内容 |
|------|---------|
| `options.h` | 添加 `UPNPUPNPMAXLIFETIME` 枚举值 |
| `options.c` | 添加 `upnp_max_lifetime` 配置解析 |
| `upnpglobalvars.h` | 添加 `upnp_max_lifetime` 全局变量声明 |
| `upnpglobalvars.c` | 添加 `upnp_max_lifetime` 全局变量定义 |
| `miniupnpd.c` | 添加配置解析逻辑 |
| `upnpsoap.c` | 修改有效时间限制逻辑 |

## 验证方法

### 检查配置是否生效

```bash
# 检查配置文件
cat /var/etc/miniupnpd.conf | grep upnp_max_lifetime

# 应该显示
upnp_max_lifetime=3600
```

### 检查 UPnP 规则

```bash
# 查看当前 UPnP 规则
ubus call luci.upnp get_status

# 检查 expires 字段，应该接近 upnp_max_lifetime 的值
```

### 测试结果

| 设备 | 原有效时间 | 新有效时间 | 状态 |
|------|-----------|-----------|------|
| 192.168.1.6 (NAS) | 604800秒 (168小时) | 3600秒 (1小时) | ✅ 生效 |
| 192.168.1.224 (迅雷) | 604800秒 (168小时) | 3600秒 (1小时) | ✅ 生效 |

## 常见问题

### Q: 为什么设置后没有立即生效？

A: UPnP 客户端有自己的刷新定时器，通常是有效时间的一半。例如设置 3600秒，客户端会在 1800秒后刷新。

### Q: 为什么迅雷需要很久才触发？

A: 迅雷使用 UPnP IGD 协议，有自己的内部定时器。重启迅雷后需要等待一段时间才会重新请求 UPnP。

### Q: upnp_max_lifetime 和 max_lifetime 有什么区别？

A: 
- `upnp_max_lifetime`: 控制 **UPnP IGD** 协议的有效时间
- `max_lifetime`: 控制 **PCP** 协议的有效时间

### Q: 最小值和最大值是多少？

A: 
- 最小值: 120秒（2分钟）
- 最大值: 604800秒（168小时）

## 基于

- OpenWrt master
- ImmortalWrt master
- miniupnpd 2.3.9

## 许可证

- miniupnpd: BSD-3-Clause
- luci-app-upnp: Apache-2.0

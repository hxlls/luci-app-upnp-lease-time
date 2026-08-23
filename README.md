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
    └── src/                # 修改后的源码文件（参考）
        ├── options.h
        ├── options.c
        ├── upnpglobalvars.h
        ├── upnpglobalvars.c
        ├── miniupnpd.c
        └── upnpsoap.c
```

## 安装方法

### 方法1：使用部署脚本

```bash
git clone https://github.com/hxlls/luci-app-upnp-lease-time.git
cd luci-app-upnp-lease-time
bash deploy.sh /path/to/openwrt
```

### 方法2：手动修改

1. 复制 luci-app-upnp 到 `feeds/luci/applications/`
2. 复制 miniupnpd 配置文件到 `feeds/packages/net/miniupnpd/files/`
3. 根据 `miniupnpd/src/` 中的文件修改 miniupnpd 源码

## 源码修改说明

### 1. options.h

在 `UPNPPCPALLOWTHIRDPARTY` 后添加：
```c
UPNPUPNPMAXLIFETIME,		/* maximum lifetime for UPnP IGD mapping */
```

### 2. options.c

在 `pcp_allow_thirdparty` 后添加：
```c
{ UPNPUPNPMAXLIFETIME, "upnp_max_lifetime"},
```

### 3. upnpglobalvars.h

添加声明：
```c
extern unsigned long int upnp_max_lifetime;
```

### 4. upnpglobalvars.c

添加定义：
```c
unsigned long int upnp_max_lifetime = 604800;
```

### 5. miniupnpd.c

在 `UPNPPCPMAXLIFETIME` 处理后添加：
```c
case UPNPUPNPMAXLIFETIME:
    upnp_max_lifetime = atoi(ary_options[i].value);
    if(upnp_max_lifetime < 120) upnp_max_lifetime = 120;
    if(upnp_max_lifetime > 604800) upnp_max_lifetime = 604800;
    break;
```

### 6. upnpsoap.c

修改有效时间限制：
```c
// 原代码
if(leaseduration == 0 || leaseduration > 604800)
    leaseduration = 604800;

// 修改后
if(leaseduration == 0 || leaseduration > upnp_max_lifetime)
    leaseduration = upnp_max_lifetime;
```

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

## 验证方法

```bash
# 检查配置文件
cat /var/etc/miniupnpd.conf | grep upnp_max_lifetime

# 查看当前 UPnP 规则
ubus call luci.upnp get_status
```

## 基于

- OpenWrt master
- ImmortalWrt master
- miniupnpd 2.3.9

## 许可证

- miniupnpd: BSD-3-Clause
- luci-app-upnp: Apache-2.0

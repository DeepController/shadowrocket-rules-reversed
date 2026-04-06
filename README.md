# Shadowrocket Rules Reversed

基于 [GMOogway/shadowrocket-rules](https://github.com/GMOogway/shadowrocket-rules) 取反的 Shadowrocket 规则，适用于**海外用户回国访问**场景。

## 规则逻辑

| 流量类型 | 原始规则 | 取反后 |
|---------|---------|--------|
| 国内域名/IP | DIRECT（直连） | **PROXY（代理）** |
| 国外域名/IP | PROXY（代理） | **DIRECT（直连）** |
| 广告/追踪 | REJECT（拦截） | REJECT（不变） |
| 未匹配流量 | PROXY | **DIRECT** |

简单来说：**国内流量走代理，国外流量直连**。

## 文件说明

| 文件 | 说明 |
|------|------|
| `sr_direct_list.module` | 国内域名 → PROXY（取反后） |
| `sr_proxy_list.module` | 国外域名 → DIRECT（取反后） |
| `sr_reject_list.module` | 广告拦截规则（保持不变） |
| `shadowrocket_reversed.conf` | 基础配置（`GEOIP,CN,PROXY` + `FINAL,DIRECT`） |

## 使用方法

1. Shadowrocket 中导入 `shadowrocket_reversed.conf` 作为基础配置
2. 添加以下 module URL（自动更新）：
   - `https://raw.githubusercontent.com/DeepController/shadowrocket-rules-reversed/master/sr_direct_list.module`
   - `https://raw.githubusercontent.com/DeepController/shadowrocket-rules-reversed/master/sr_proxy_list.module`
   - `https://raw.githubusercontent.com/DeepController/shadowrocket-rules-reversed/master/sr_reject_list.module`

## 自动更新

GitHub Actions 每天自动从上游拉取最新规则并取反。如果上游无变化则跳过提交。

也可在 Actions 页面手动触发更新。

## 致谢

规则数据来源于 [GMOogway/shadowrocket-rules](https://github.com/GMOogway/shadowrocket-rules)，本项目遵循 GPL v3 许可证。

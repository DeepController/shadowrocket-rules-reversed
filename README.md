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
| `shadowrocket_reversed.conf` | 基础配置（`GEOIP,CN,PROXY` + `FINAL,DIRECT` + IPv6 开启） |

## 使用方法

### 第一步：导入基础配置

1. 复制配置文件的 raw URL：
   ```
   https://raw.githubusercontent.com/DeepController/shadowrocket-rules-reversed/master/shadowrocket_reversed.conf
   ```
2. 打开 Shadowrocket → 底部导航栏点击「配置」
3. 点击右上角 `+`，将上面的 URL 粘贴进去，点击「下载」
4. 下载完成后，点击该配置文件，选择「使用配置」

### 第二步：添加 Module（模块）

1. 打开 Shadowrocket → 底部导航栏点击「配置」→ 点击「模块」
2. 点击右上角 `+`，依次添加以下三个模块 URL：

   **国内域名走代理：**
   ```
   https://raw.githubusercontent.com/DeepController/shadowrocket-rules-reversed/master/sr_direct_list.module
   ```

   **国外域名走直连：**
   ```
   https://raw.githubusercontent.com/DeepController/shadowrocket-rules-reversed/master/sr_proxy_list.module
   ```

   **广告拦截：**
   ```
   https://raw.githubusercontent.com/DeepController/shadowrocket-rules-reversed/master/sr_reject_list.module
   ```

3. 添加完成后，确保三个模块的开关都已打开

### 第三步：配置代理服务器

1. 回到 Shadowrocket 首页，点击右上角 `+` 添加你的回国代理节点
2. 填入服务器地址、端口、密码等信息
3. 选中该节点，打开顶部的连接开关即可

## 自动更新

- GitHub Actions 每天 UTC 0:00（北京时间 8:00）自动从上游拉取最新规则并取反
- 上游无变化时跳过提交，不会产生空 commit
- 也可在 [Actions 页面](https://github.com/DeepController/shadowrocket-rules-reversed/actions) 手动触发更新
- Shadowrocket 会定期自动更新已添加的模块，也可在「模块」页面手动下拉刷新

## 致谢

规则数据来源于 [GMOogway/shadowrocket-rules](https://github.com/GMOogway/shadowrocket-rules)，本项目遵循 GPL v3 许可证。

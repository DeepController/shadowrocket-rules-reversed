#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Shadowrocket 规则取反脚本
# 原始仓库: https://github.com/GMOogway/shadowrocket-rules
# 目的: 国内流量走代理 (PROXY)，国外流量直连 (DIRECT)
# =============================================================================

REPO_BASE="https://raw.githubusercontent.com/GMOogway/shadowrocket-rules/master"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMP_DIR="$(mktemp -d)"
OUTPUT_DIR="$SCRIPT_DIR"
DATE_STR="$(date '+%m-%d %H:%M')"

# 跨平台 sed -i 兼容 (macOS 需要 -i ''，Linux 需要 -i)
sedi() {
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

trap 'rm -rf "$TEMP_DIR"' EXIT

echo "==> 下载原始规则文件..."
curl -sL "$REPO_BASE/sr_direct_list.module"  -o "$TEMP_DIR/sr_direct_list.module"
curl -sL "$REPO_BASE/sr_proxy_list.module"   -o "$TEMP_DIR/sr_proxy_list.module"
curl -sL "$REPO_BASE/sr_reject_list.module"  -o "$TEMP_DIR/sr_reject_list.module"

# 验证下载成功
for f in sr_direct_list.module sr_proxy_list.module sr_reject_list.module; do
    if [[ ! -s "$TEMP_DIR/$f" ]]; then
        echo "错误: 下载 $f 失败" >&2
        exit 1
    fi
done

echo "==> 取反规则: DIRECT <-> PROXY ..."

# ---- sr_direct_list.module → 国内域名走代理 ----
# 原: 国内域名 DIRECT → 改为 PROXY
DIRECT_COUNT=$(grep -c ',DIRECT$' "$TEMP_DIR/sr_direct_list.module" || true)
sed 's/,DIRECT$/,PROXY/g' "$TEMP_DIR/sr_direct_list.module" > "$OUTPUT_DIR/sr_direct_list.module"
# 更新 header
sedi "s/^#!name=.*/#!name=direct_list_reversed/" "$OUTPUT_DIR/sr_direct_list.module"
sedi "s/^#!desc=.*/#!desc=Reversed(CN->PROXY) Rules:${DIRECT_COUNT} Updated:${DATE_STR} Source:GMOogway/" "$OUTPUT_DIR/sr_direct_list.module"

# ---- sr_proxy_list.module → 国外域名走直连 ----
# 原: 国外域名 PROXY → 改为 DIRECT
PROXY_COUNT=$(grep -c ',PROXY$' "$TEMP_DIR/sr_proxy_list.module" || true)
sed 's/,PROXY$/,DIRECT/g' "$TEMP_DIR/sr_proxy_list.module" > "$OUTPUT_DIR/sr_proxy_list.module"
# 更新 header
sedi "s/^#!name=.*/#!name=proxy_list_reversed/" "$OUTPUT_DIR/sr_proxy_list.module"
sedi "s/^#!desc=.*/#!desc=Reversed(Foreign->DIRECT) Rules:${PROXY_COUNT} Updated:${DATE_STR} Source:GMOogway/" "$OUTPUT_DIR/sr_proxy_list.module"

# ---- sr_reject_list.module → 广告拦截保持不变 ----
cp "$TEMP_DIR/sr_reject_list.module" "$OUTPUT_DIR/sr_reject_list.module"

echo "==> 生成取反后的基础配置..."

cat > "$OUTPUT_DIR/shadowrocket_reversed.conf" << 'CONF'
# Shadowrocket 取反配置
# 国内流量走代理，国外流量直连
# 配合取反后的 module 文件使用

[General]
bypass-system = true
skip-proxy = 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, localhost, *.local, captive.apple.com
dns-server = https://cloudflare-dns.com/dns-query, https://dns.google/dns-query
ipv6 = false

[Rule]
# 中国大陆 IP 走代理
GEOIP,CN,PROXY
# 默认直连（国外流量）
FINAL,DIRECT

CONF

echo "==> 完成!"
echo "    sr_direct_list.module : ${DIRECT_COUNT} 条规则 (CN 域名 → PROXY)"
echo "    sr_proxy_list.module  : ${PROXY_COUNT} 条规则 (外国域名 → DIRECT)"
echo "    sr_reject_list.module : 广告拦截 (保持 REJECT 不变)"
echo "    shadowrocket_reversed.conf : 基础配置 (GEOIP CN → PROXY, FINAL → DIRECT)"

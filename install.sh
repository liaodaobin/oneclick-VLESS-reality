#!/bin/bash

# 定义颜色输出
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN="\033[0m"

echo -e "${GREEN}======================================================${PLAIN}"
echo -e "${GREEN}    Sing-box VLESS+Reality 随机端口防扫描一键部署    ${PLAIN}"
echo -e "${GREEN}======================================================${PLAIN}"

# 0. 检查 Root 权限
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}错误：必须使用 root 用户运行此脚本！${PLAIN}"
    exit 1
fi

echo -e "\n${YELLOW}正在准备环境并安装必要组件...${PLAIN}"

# 1. 更新系统并安装所有必备工具
apt-get update -y
apt-get install -y curl wget jq openssl qrencode

# 2. 检查并安装 Sing-box 核心
if ! command -v sing-box &> /dev/null; then
    echo -e "${YELLOW}正在安装 Sing-box 官方核心...${PLAIN}"
    bash <(curl -fsSL https://sing-box.app/deb-install.sh)
fi

# 3. 获取用户输入
echo ""
read -p "请输入你想使用的伪装域名 SNI (直接回车默认: www.microsoft.com): " CUSTOM_SNI
SNI=${CUSTOM_SNI:-www.microsoft.com}

# 4. 正确生成各种参数
echo -e "\n${YELLOW}正在生成高强度加密凭证及随机端口...${PLAIN}"
UUID=$(sing-box generate uuid)
KEYS=$(sing-box generate reality-keypair)
PRIVATE_KEY=$(echo "$KEYS" | grep -i "Private" | awk '{print $2}')
PUBLIC_KEY=$(echo "$KEYS" | grep -i "Public" | awk '{print $2}')
SHORT_ID=$(openssl rand -hex 8)
PORT=$(shuf -i 10000-60000 -n 1)
IP=$(curl -s4 https://api.ipify.org)

echo -e "${YELLOW}正在写入配置文件...${PLAIN}"
# 注意：listen 改为 0.0.0.0，修复缺少 IPv6 环境的 VPS 启动失败问题
cat <<EOF > /etc/sing-box/config.json
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "0.0.0.0",
      "listen_port": $PORT,
      "users": [
        {
          "uuid": "$UUID",
          "flow": "xtls-rprx-vision"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "$SNI",
        "reality": {
          "enabled": true,
          "handshake": {
            "server": "$SNI",
            "server_port": 443
          },
          "private_key": "$PRIVATE_KEY",
          "short_id": [
            "$SHORT_ID"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ]
}
EOF

# 5. 重启服务并设置开机自启
echo -e "${YELLOW}正在启动 Sing-box 服务...${PLAIN}"
systemctl enable sing-box >/dev/null 2>&1
systemctl restart sing-box
sleep 2

# 6. 验证并输出结果
if systemctl is-active --quiet sing-box; then
    VLESS_LINK="vless://${UUID}@${IP}:${PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${SNI}&fp=chrome&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=tcp&headerType=none#Secure-VLESS"
    
    echo -e "\n${GREEN}======================================================${PLAIN}"
    echo -e "${GREEN}🎉 节点配置成功！${PLAIN}"
    echo -e "${GREEN}------------------------------------------------------${PLAIN}"
    echo -e "${YELLOW}专属 VLESS 链接：${PLAIN}"
    echo -e "\n${VLESS_LINK}\n"
    echo -e "${GREEN}------------------------------------------------------${PLAIN}"
    echo -e "${YELLOW}手机端请直接扫描下方二维码导入：${PLAIN}\n"
    
    # 使用 qrencode 在终端输出 UTF-8 格式的二维码
    qrencode -t ANSIUTF8 "$VLESS_LINK"
    
    echo -e "\n${GREEN}======================================================${PLAIN}"
else
    echo -e "\n${RED}启动失败！${PLAIN}"
    echo -e "请运行 ${YELLOW}journalctl -u sing-box --no-pager${PLAIN} 查看具体报错信息。"
fi

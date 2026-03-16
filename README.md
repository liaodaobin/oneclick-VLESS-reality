# oneclick-VLESS-reality
我的第一个GitHub仓库，用于学习
# Sing-box VLESS+Reality 随机特征防扫描一键部署

这是一个轻量级、高隐蔽性的 VLESS+Reality 节点一键部署脚本。基于官方 Sing-box 核心构建。

## 💡 为什么选择这个脚本？（与大众模板的区别）
目前市面上很多一键脚本使用固定的配置模板和常见的默认端口（如 443 或 80），很容易被 GFW 提取统一特征并进行批量扫描和封锁。
本项目专为 **“防主动探测”** 打造：
- 🎲 **全随机端口**：每次安装随机分配 10000-60000 之间的高位端口。
- 🔑 **全动态特征**：UUID、Reality 公私钥、Short ID 安装时即时生成，千人千面。
- 🛡️ **底层安全**：监听 `0.0.0.0` 兼容各种双栈或单栈 IPv4/IPv6 VPS，强制启用 `xtls-rprx-vision` 流控。
- 📦 **极简纯净**：无任何多余面板和臃肿进程，只做纯粹的节点代理。

## 💡推荐客户端：

Windows: v2rayN
Android: v2rayNG / Clash Meta
iOS: Shadowrocket / FoXray / Streisand
Mac: V2RayU / Shadowrocket
软路由passwall

## 🚀 一键安装命令

在你的 VPS 终端（需 Root 权限）中粘贴并回车运行：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/liaodaobin/oneclick-VLESS-reality/main/install.sh)


安装完成后，终端会直接输出 VLESS-reality-singbox 链接以及 高清二维码。



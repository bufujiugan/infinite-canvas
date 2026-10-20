# Windows 本机部署

本仓库基于 tigerowo/infinite-canvas，保留原始许可证与源码。Windows 部署入口位于根目录。

## 准备

1. 安装 Node.js，确保 `node` 在 PATH 中。
2. 将 Go 1.25 或兼容版本解压到 `.runtime/go`，确保存在 `.runtime/go/bin/go.exe`。
3. 将 Bun 1.3.14 Windows x64 解压到 `.runtime/bun-1.3.14/bun-windows-x64`，确保存在 `bun.exe`。
4. 复制 `.env.example` 为 `.env`，设置自己的 `ADMIN_USERNAME`、`ADMIN_PASSWORD` 和随机 `JWT_SECRET`，并设置 `PORT=18080`。保留 SQLite 配置即可。

## 构建和运行

在仓库根目录运行：

```powershell
.\build-local.ps1
.\start-local.ps1
```

前端地址为 `http://127.0.0.1:3000`，后端监听 `18080`。启动脚本在后台运行服务，日志保存在 `logs/`。这两个端口需空闲。

停止服务：

```powershell
.\stop-local.ps1
```

## 上游渠道

登录本机管理员账号，进入「系统设置 → 私有配置 → 新增渠道」，填写接口地址和凭证，选择模型及其分类。保存渠道后点击页面顶部「保存设置」。

再进入「公开配置」，选择系统可用模型和默认图片/视频模型，按需开启「允许普通用户使用云端渠道」，点击「保存设置」。生图工作台使用 `images` 接口模式。

API Key 与网页登录会话 Token 不同，必须配合上游对应的接口地址使用。会话 Token 会过期，需要重新登录上游并更新本机私有渠道凭证；浏览器重新登录不会自动更新该配置。

## 本机数据

`.env`、`data/`（SQLite、账号和渠道凭证）、`.runtime/`、`dist/`、`output/`、日志和浏览器自动化缓存均不提交 Git。克隆仓库不会带入已有账号、上游密钥或生成记录；需要自行构建并配置。备份数据库时应按敏感文件保管。

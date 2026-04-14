# 🔑 如何获取 GitHub Personal Access Token

## 第 1 步：进入 GitHub Settings

1. 登录 GitHub
2. 点击右上角头像 → **Settings**
3. 左侧菜单 → **Developer settings** → **Personal access tokens** → **Tokens (classic)**

## 第 2 步：创建新 Token

1. 点击 **Generate new token** → **Generate new token (classic)**

## 第 3 步：配置 Token 权限

**Token name**: `homestay-expense-config`

**Expiration**: 选择 **30 days**（足够完成部署）

**Select scopes**（勾选以下权限）:
- ✅ `repo` （完整的仓库访问）
  - `repo:status` 
  - `repo_deployment`
  - `public_repo`
  - `repo:invite` 
- ✅ `workflow` （Actions 工作流）
- ✅ `admin:repo_hook` （仓库 hooks）
- ✅ `admin:org` 

## 第 4 步：生成 Token

1. 点击 **Generate token**
2. **立即复制** token（这是唯一显示的时候！）
3. 保存到安全的地方

## ⚠️ 安全说明

- ❌ 不要提交 token 到 Git
- ✅ token 应该只用于自动化脚本
- 🔄 部署完成后删除 token（在 GitHub Settings 中）

---

## 然后运行此命令

```powershell
$token = "your_github_token_here"
powershell -ExecutionPolicy Bypass -Command {
    param([string]$Token)
    & 'c:\Users\localad\Desktop\homestay-expenses\auto-configure-github.ps1' -GitHubToken $Token
} -ArgumentList $token
```

**或简单地**:

```powershell
$token = Read-Host "Enter your GitHub token"
& 'c:\Users\localad\Desktop\homestay-expenses\auto-configure-github.ps1' -GitHubToken $token
```

---

还有一个替代方法：**使用 gh CLI**（如果你愿意安装的话）

```powershell
gh auth login
gh secret set SUPABASE_URL --body "https://skwogboredsczcyhlqgn.supabase.co" -R haujackpang/homestayERP-prod
# ... 继续对所有 Secrets 和两个仓库
```

但第一个方法更快。

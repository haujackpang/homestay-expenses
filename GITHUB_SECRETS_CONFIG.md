# 🔐 GitHub Secrets 配置 - 快速参考

**生成时间**: 2026-04-14  
**状态**: 准备配置 ⏳

---

## 第一步：配置 Prod 仓库 Secrets

### 🔗 直接链接：
[👉 打开 Prod Repository Secrets](https://github.com/haujackpang/homestayERP-prod/settings/secrets/actions)

### 需要添加的 3 个 Secrets：

| 名称 | 值 |
|------|-----|
| `SUPABASE_URL` | `https://skwogboredsczcyhlqgn.supabase.co` |
| `SUPABASE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0` |
| `SUPABASE_SERVICE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDI1MzY5OSwiZXhwIjoyMDg5ODI5Njk5fQ.VuxUoTz2SRMqRLaYhZtqfrjfNLVyEKMF3v4MU_mfVoY` |

### 配置步骤：
1. ✅ 打开上面的链接
2. ✅ 点击 **"New repository secret"**
3. ✅ 依次添加上表中的 3 个 Secret
4. ✅ 每个 Secret 名称**必须完全匹配**（注意大小写）

---

## 第二步：配置 Test 仓库 Secrets

### 🔗 直接链接：
[👉 打开 Test Repository Secrets](https://github.com/haujackpang/homestayERP-test/settings/secrets/actions)

### 需要添加的 3 个 Secrets：

| 名称 | 值 |
|------|-----|
| `SUPABASE_URL` | `https://afcifzghlkxvnpulahub.supabase.co` |
| `SUPABASE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0` |
| `SUPABASE_SERVICE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmY2lmemdobGt4dm5wdWxhaHViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5OTExMSwiZXhwIjoyMDkxNjc1MTExfQ.BQIAxXsdq5D5CtFeJ-AqYzQ-jJhzsZYz9hQOpEofg-Q` |

### 配置步骤：
1. ✅ 打开上面的链接
2. ✅ 点击 **"New repository secret"**
3. ✅ 依次添加上表中的 3 个 Secret
4. ✅ 每个 Secret 名称**必须完全匹配**（注意大小写）

---

## 第三步：启用 GitHub Pages

### Prod 仓库 Pages 配置：

[👉 打开 Prod Pages 设置](https://github.com/haujackpang/homestayERP-prod/settings/pages)

**步骤**:
1. 找到 **Source** 部分
2. 从下拉菜单选择 **GitHub Actions**
3. 点击 **Save**

### Test 仓库 Pages 配置：

[👉 打开 Test Pages 设置](https://github.com/haujackpang/homestayERP-test/settings/pages)

**步骤**:
1. 找到 **Source** 部分
2. 从下拉菜单选择 **GitHub Actions**
3. 点击 **Save**

---

## ✅ 完成后监控部署

### 查看部署日志：

- 📱 **Prod 部署**: https://github.com/haujackpang/homestayERP-prod/actions
- 🧪 **Test 部署**: https://github.com/haujackpang/homestayERP-test/actions

**等待状态**: 应该在 2-3 分钟内显示 ✅ (绿色勾号)

---

## 🌍 访问部署的应用

部署完成后: 

- 📱 **Prod App**: https://haujackpang.github.io/homestayERP-prod
- 🧪 **Test App**: https://haujackpang.github.io/homestayERP-test

如果看到 **"Home Expense Tracker"** 表单，说明部署成功！🎉

---

## 🔍 故障排除

### 部署失败？
- 检查 Secrets 名称是否**完全正确**（包括大小写）
- 检查 SUPABASE_URL 没有多余空格
- 查看 Actions 日志寻找具体错误信息

### 网页显示 404？
- 确认 Pages Source 设置为 **GitHub Actions**
- 等待 3-5 分钟后重新加载
- 按 `Ctrl+Shift+Del` 清除浏览器缓存

---

**所有配置完成后，请告诉我！** 我会帮助你验证部署状态。

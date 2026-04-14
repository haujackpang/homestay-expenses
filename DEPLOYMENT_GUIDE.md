# 🚀 Test 环境部署完整指南

**状态**: 数据迁移 ✅ | Secrets 配置 ⏳ | Pages 启用 ⏳ | 验证 ⏳

---

## 第一部分：收集必要的凭证

### 1️⃣ Prod 项目凭证（已收集）
```
项目 URL: https://skwogboredsczcyhlqgn.supabase.co
Anon Key (SUPABASE_KEY):
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0
```

### 2️⃣ Prod Service Role Key（需要手动获取）

**步骤**:
1. 打开 [Supabase Dashboard - Prod](https://app.supabase.com/)
2. 选择 **homestayERP-prod** 项目
3. 左侧菜单 → **Settings** → **API**
4. 在 "Project API keys" 部分，找到 **service_role** 的密钥（标签为 "secret"）
5. 📋 **复制该密钥** ← 稍后需要用到

---

### 3️⃣ Test 项目凭证（需要从 Supabase 获取）

**步骤**:
1. 打开 [Supabase Dashboard - Test](https://app.supabase.com/)
2. 选择 **homestayERP-test** 项目
3. 左侧菜单 → **Settings** → **API**
4. 复制以下 **3 个** 密钥：
   - **Anon Key** (你的公开密钥)
   - **Service Role Key** (标记为 "secret")

---

## 第二部分：配置 GitHub Secrets

### 📦 Prod 仓库（homestayERP-prod）

1. 打开 GitHub 并进入 [homestayERP-prod 仓库](https://github.com/haujackpang/homestayERP-prod)
2. **Settings** → **Secrets and variables** → **Actions** 
3. 点击 **New repository secret** 添加 **3 个** 密钥：

```yaml
1️⃣ SUPABASE_URL
   Value: https://skwogboredsczcyhlqgn.supabase.co

2️⃣ SUPABASE_KEY  
   Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0

3️⃣ SUPABASE_SERVICE_KEY
   Value: (从第 2️⃣ 步复制的 Prod Service Role Key)
```

---

### 🧪 Test 仓库（homestayERP-test）

1. 打开 GitHub 并进入 [homestayERP-test 仓库](https://github.com/haujackpang/homestayERP-test)
2. **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret** 添加 **3 个** 密钥：

```yaml
1️⃣ SUPABASE_URL
   Value: https://afcifzghlkxvnpulahub.supabase.co

2️⃣ SUPABASE_KEY
   Value: (从第 3️⃣ 步复制的 Test Anon Key)

3️⃣ SUPABASE_SERVICE_KEY
   Value: (从第 3️⃣ 步复制的 Test Service Role Key)
```

---

## 第三部分：启用 GitHub Pages

### 📱 Prod 仓库：

1. 进入 [homestayERP-prod 仓库](https://github.com/haujackpang/homestayERP-prod)
2. **Settings** → **Pages**
3. **Source**: 选择 **GitHub Actions**
4. 保存

### 🧪 Test 仓库：

1. 进入 [homestayERP-test 仓库](https://github.com/haujackpang/homestayERP-test)
2. **Settings** → **Pages**
3. **Source**: 选择 **GitHub Actions**
4. 保存

---

## 第四部分：触发部署

### 提交更改以触发工作流：

```bash
# 在 Prod 仓库中
cd c:\Users\localad\Desktop\homestay-expenses
git add .
git commit -m "Phase 4: Configure environment secrets"
git push origin main
```

### 监控部署状态：

1. 进入仓库 → **Actions** 选项卡
2. 查看最新的 "Deployment" 工作流
3. 等待状态变为 ✅ **成功**

---

## 第五部分：验证部署

部署完成后（约 1-2 分钟），访问以下 URLs：

- 📱 **Prod URL**: https://haujackpang.github.io/homestayERP-prod
- 🧪 **Test URL**: https://haujackpang.github.io/homestayERP-test

如果看到 Home Expense 表单，说明部署成功！ 🎉

---

## ⚠️ 注意事项

- ❌ 不要在公开的 Git 历史记录中提交密钥
- ✅ 使用 GitHub Secrets 来存储敏感信息
- 🔄 每次修改都会自动触发部署
- 🛡️ Test 环境用于开发测试，Prod 用于生产

---

## 🆘 故障排除

### 部署失败？
- 检查 **Actions** 选项卡中的错误日志
- 确认所有 Secrets 名称**完全匹配**（区分大小写）
- 确认 Supabase URLs 正确

### 无法访问 Pages URL？
- 确认Pages Source 设置为 **GitHub Actions**
- 等待 3-5 分钟后重试
- 清除浏览器缓存（Ctrl+Shift+Del）

---

**下一步**：完成上述所有步骤后，告诉我你已完成，我会验证部署状态！

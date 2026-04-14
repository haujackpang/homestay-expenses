# 🚀 GitHub 配置完整清单

## 第一部分：配置 Prod 仓库 Secrets

### 📍 打开此链接：
```
https://github.com/haujackpang/homestayERP-prod/settings/secrets/actions
```

### 📋 添加 3 个 Secrets：

**第 1 个 Secret:**
- **Name:** `SUPABASE_URL`
- **Value:** `https://skwogboredsczcyhlqgn.supabase.co`
- 点击 "Add secret" ✅

**第 2 个 Secret:**
- **Name:** `SUPABASE_KEY`
- **Value:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0`
- 点击 "Add secret" ✅

**第 3 个 Secret:**
- **Name:** `SUPABASE_SERVICE_KEY`
- **Value:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDI1MzY5OSwiZXhwIjoyMDg5ODI5Njk5fQ.VuxUoTz2SRMqRLaYhZtqfrjfNLVyEKMF3v4MU_mfVoY`
- 点击 "Add secret" ✅

---

## 第二部分：配置 Test 仓库 Secrets

### 📍 打开此链接：
```
https://github.com/haujackpang/homestayERP-test/settings/secrets/actions
```

### 📋 添加相同的 3 个 Secrets（TEST 仓库）：

**第 1 个 Secret:**
- **Name:** `SUPABASE_URL`
- **Value:** `https://afcifzghlkxvnpulahub.supabase.co`
- 点击 "Add secret" ✅

**第 2 个 Secret:**
- **Name:** `SUPABASE_KEY`
- **Value:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0`
- 点击 "Add secret" ✅

**第 3 个 Secret:**
- **Name:** `SUPABASE_SERVICE_KEY`
- **Value:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmY2lmemdobGt4dm5wdWxhaHViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5OTExMSwiZXhwIjoyMDkxNjc1MTExfQ.BQIAxXsdq5D5CtFeJ-AqYzQ-jJhzsZYz9hQOpEofg-Q`
- 点击 "Add secret" ✅

---

## 第三部分：启用 Prod Pages

### 📍 打开此链接：
```
https://github.com/haujackpang/homestayERP-prod/settings/pages
```

### ⚙️ 步骤：
1. 找到 **"Source"** 部分
2. 从下拉菜单选择 **"GitHub Actions"**
3. 点击 **"Save"** ✅

---

## 第四部分：启用 Test Pages

### 📍 打开此链接：
```
https://github.com/haujackpang/homestayERP-test/settings/pages
```

### ⚙️ 步骤：
1. 找到 **"Source"** 部分
2. 从下拉菜单选择 **"GitHub Actions"**
3. 点击 **"Save"** ✅

---

## 第五部分：验证部署

### 📊 检查 GitHub Actions 状态

**Prod 仓库：**
```
https://github.com/haujackpang/homestayERP-prod/actions
```
- 应该显示绿色 ✅ 或黄色 ⏳ 状态
- 等待 2-3 分钟直到显示绿色 ✅

**Test 仓库：**
```
https://github.com/haujackpang/homestayERP-test/actions
```
- 应该显示绿色 ✅ 或黄色 ⏳ 状态
- 等待 2-3 分钟直到显示绿色 ✅

---

## 第六部分：访问你的应用

### 🎉 部署完成后，访问：

**Prod 应用:**
```
https://haujackpang.github.io/homestayERP-prod
```

**Test 应用:**
```
https://haujackpang.github.io/homestayERP-test
```

如果看到 **"Home Expense Tracker"** 表单，说明部署成功！🎉

---

## ✅ 完成检查

- [ ] Prod 仓库：3 个 Secrets 已添加
- [ ] Test 仓库：3 个 Secrets 已添加
- [ ] Prod Pages：已启用
- [ ] Test Pages：已启用
- [ ] Prod Actions：已完成（绿色 ✅）
- [ ] Test Actions：已完成（绿色 ✅）
- [ ] Prod App：可访问
- [ ] Test App：可访问

---

**完成上述所有步骤后，告诉我！我会帮你验证一切是否正常运行。** ✅

# Homestay Expense System — 项目指引

## 语言

- 始终使用**中文**回复

## 架构

- **单文件 SPA**：整个前端在 `home_expense.htm` 一个文件里（HTML + CSS + JS），不要创建新的 JS/CSS 文件
- **后端**：Supabase（PostgreSQL + Auth + Storage + Edge Functions）
- **Edge Functions**：Deno 运行时，TypeScript，位于 `supabase/functions/`
- **AI 分析**：通过 OpenRouter API 调用免费模型（Gemma/Mistral），有多模型 fallback
- **Android**：`android-app/` 是 WebView 壳，加载本地 `home_expense.htm`
- **部署**：Netlify（网页），Supabase（后端），APK（Android）

## 前端模式（必须遵守）

- **状态管理**：全局变量 + `render()` 函数重绘整个 UI
- **页面切换**：`ss('screenName', 'previousScreen')` 函数
- **事件处理**：所有 handler 必须注册到 `window.xxx = function(){...}`，因为 HTML 用 `onclick="xxx()"`
- **DB 操作**：统一用 `dbXxx` 函数封装（`dbInsertClaim`, `dbUpdateClaim`, `dbDeleteClaim`），不要在业务逻辑里直接写 `sb.from().xxx()`
- **Toast 提示**：`toast('消息')` 函数
- **权限检查**：`empCanEdit()`, `empCanDelete()`, `mgrCanEdit()`, `isPaidOut()` 等 helper

## Android 同步（关键！）

**每次修改 `home_expense.htm` 后，必须同步到 Android 资源目录：**

```
home_expense.htm → android-app/app/src/main/assets/home_expense.htm
```

可以用命令：`Copy-Item home_expense.htm android-app/app/src/main/assets/home_expense.htm -Force`

如果忘记同步，Android 版本的 app 会和网页版不一致。

## 数据库

- 表结构：`claims`, `profiles`, `bank_info`, `error_logs`, `claim_counter`
- Claim 状态：`Draft`, `Submitted`, `Approved`, `Rejected`, `Claimed`, `Auto-Approved`, `Company-Paid`
- 支付类型：`employee`（需报销）, `company`（公司付款，仅记录）
- 货币：Malaysian Ringgit (RM)

## Supabase 配置

- Project URL: `https://afcifzghlkxvnpulahub.supabase.co`
- RLS 策略在 `fix-policies.sql` 和 `supabase-setup.sql`
- Edge Function 需要环境变量：`OPENROUTER_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY`

## 添加新功能的步骤

1. 在 `home_expense.htm` 中添加 DB 函数（如果需要）
2. 添加 helper 函数
3. 在 `render()` 函数的对应 screen 分支中添加 UI
4. 注册 `window.xxx` handler
5. **同步到 Android 资源目录**

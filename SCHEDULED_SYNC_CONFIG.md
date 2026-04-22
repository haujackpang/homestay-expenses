# 定时预订数据同步配置说明

此文档说明如何配置 Test 和 Live 环境的自动预订同步任务。

## Live 环境配置（已完成）

Live project（Project ID: skwogboredsczcyhlqgn）已配置定时同步任务：
- **频率**：每 5 分钟
- **任务名**：`sync-reservations-live-every-5-minutes`
- **调用**：Edge Function `/functions/v1/sync-reservations`

## Test 环境配置（手动操作）

Test project（Project ID: afcifzghlkxvnpulahub）需要手动配置定时任务。

### 步骤 1：获取 Test 项目的 API 密钥

1. 登录 Supabase Dashboard
2. 选择 Test project（afcifzghlkxvnpulahub）
3. 进入 **Settings > API**
4. 复制 **anon** 密钥（以 `eyJ...` 开头）

### 步骤 2：在 Test 项目中运行 SQL

1. 在 Test project 中打开 **SQL Editor**
2. 创建新的 SQL 查询
3. 粘贴以下 SQL 代码（替换 `[TEST_ANON_KEY]` 为实际的 Test anon 密钥）：

```sql
-- 确保启用 pg_net 扩展
create extension if not exists pg_net with schema extensions;

-- 配置 Test 环境定时任务：每天 1 AM UTC（对应 MYT 时区 8 AM）
select cron.schedule(
  'sync-reservations-test-daily-1am',
  '0 1 * * *',  -- 每天 1 AM UTC
  $$
  select net.http_post(
    url := 'https://afcifzghlkxvnpulahub.supabase.co/functions/v1/sync-reservations',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer [TEST_ANON_KEY]'
    ),
    body := jsonb_build_object('source', 'cron'),
    timeout_milliseconds := 30000
  ) as request_id;
  $$
);
```

### 步骤 3：验证定时任务

运行以下 SQL 查询验证任务是否成功创建：

```sql
-- 查看所有定时任务
select * from cron.job where jobname like 'sync-reservations%';

-- 查看最近的执行历史（最多 10 条）
select * from cron.job_run_details 
where job_id = (select jobid from cron.job where jobname = 'sync-reservations-test-daily-1am')
order by start_time desc
limit 10;
```

## 时区说明

- **UTC 1 AM** = **MYT 9 AM**（标准时间）/ **MYT 8 AM**（如果使用 UTC+8）
- 如果需要调整时间，使用 cron 语法修改 schedule 参数

### Cron 语法参考

```
┌───────────── min (0 - 59)
│ ┌────────────── hour (0 - 23)
│ │ ┌─────────────── day of month (1 - 31)
│ │ │ ┌──────────────── month (1 - 12)
│ │ │ │ ┌───────────────── day of week (0 - 6)
│ │ │ │ │
* * * * *

示例：
0 1 * * *  = 每天 1 AM
*/5 * * * * = 每 5 分钟
0 0 * * *  = 每天午夜
0 8 * * 1  = 每周一 8 AM
```

## 监控和故障排除

### 查看同步日志

```sql
select * from sync_logs 
order by created_at desc 
limit 10;
```

### 查看定时任务执行历史

```sql
select 
  jobid,
  jobname,
  start_time,
  end_time,
  status,
  return_message,
  query
from cron.job_run_details 
order by start_time desc 
limit 20;
```

### 删除定时任务

如果需要删除定时任务：

```sql
select cron.unschedule('sync-reservations-test-daily-1am');
```

## Edge Function 环境变量

确保以下环境变量已在 Supabase 项目中配置：

- `RESERVATION_EMAIL` - Hostplatform API 账户邮箱
- `RESERVATION_PASSWORD` - Hostplatform API 密码
- `RESERVATION_API_BASE` - Hostplatform API 基础 URL

这些可以在 **Settings > Edge Functions > Environment Variables** 中配置。

## 预期行为

- **Test 环境**：每天 1 AM UTC 自动同步一次预订数据
- **Live 环境**：每 5 分钟自动同步一次预订数据
- 同步结果记录在 `sync_logs` 表中
- 成功的同步会在 `reservations` 表中创建或更新记录

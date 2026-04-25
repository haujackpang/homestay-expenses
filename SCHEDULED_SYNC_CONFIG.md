# Scheduled Sync Configuration

This document describes how scheduled HostPlatform reservation sync should be configured per environment.

## Environment Pairing

| Environment | Supabase project ref | Function URL base |
| --- | --- | --- |
| Test | `afcifzghlkxvnpulahub` | `https://afcifzghlkxvnpulahub.supabase.co/functions/v1` |
| Live | `skwogboredsczcyhlqgn` | `https://skwogboredsczcyhlqgn.supabase.co/functions/v1` |

Do not copy cron jobs, reservations, units, or sync logs between environments. Configure each project directly.

## Test Scheduled Sync Example

Use this only in the test Supabase SQL editor, replacing `[TEST_ANON_KEY]` with the test anon key:

```sql
create extension if not exists pg_net with schema extensions;

select cron.schedule(
  'sync-reservations-test-daily-1am',
  '0 1 * * *',
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

## Live Scheduled Sync Example

Use this only in the live Supabase SQL editor, replacing `[LIVE_ANON_KEY]` with the live anon key:

```sql
create extension if not exists pg_net with schema extensions;

select cron.schedule(
  'sync-reservations-live-every-5-minutes',
  '*/5 * * * *',
  $$
  select net.http_post(
    url := 'https://skwogboredsczcyhlqgn.supabase.co/functions/v1/sync-reservations',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer [LIVE_ANON_KEY]'
    ),
    body := jsonb_build_object('source', 'cron'),
    timeout_milliseconds := 30000
  ) as request_id;
  $$
);
```

## Verification

```sql
select jobid, jobname, schedule, active
from cron.job
where jobname like 'sync-reservations%'
order by jobname;
```

```sql
select *
from sync_logs
order by created_at desc
limit 10;
```

## Safety Notes

- Test sync should write only to the test project.
- Live sync should write only to the live project.
- A release to live does not mean copying test data to live.
- If a cron job points at the wrong project URL, disable it and recreate it in the correct environment.

-- 最初の既定URLを投入
insert into org_settings (default_url) values ('https://kataomoi.org');

-- テスト用のカードを作成（current_urlは自動でorg_settings.default_urlが設定される）
insert into cards (id, status, current_url, default_source) 
values 
  ('550e8400-e29b-41d4-a716-446655440000', 'preprovisioned', '', 'org_default'),
  ('550e8400-e29b-41d4-a716-446655440001', 'preprovisioned', '', 'org_default'),
  ('550e8400-e29b-41d4-a716-446655440002', 'preprovisioned', '', 'org_default');


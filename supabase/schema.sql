-- 組織既定URL（KATAOMOIのデフォルト行き先）
create table if not exists org_settings (
  org_id uuid primary key default gen_random_uuid(),
  default_url text not null,
  updated_at timestamptz not null default now()
);

-- ユーザー拡張（auth.users と1:1）
create table if not exists app_users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  created_at timestamptz not null default now()
);

-- 名刺カード（個別URLを保持）
create table if not exists cards (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid references app_users(id),
  status text not null check (status in ('preprovisioned','claimed')) default 'preprovisioned',
  current_url text not null,
  default_source text not null check (default_source in ('org_default','custom')) default 'org_default',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 引き取り用トークン（短命・1回限り）
create table if not exists claim_tokens (
  id uuid primary key default gen_random_uuid(),
  card_id uuid not null references cards(id) on delete cascade,
  user_id uuid not null references app_users(id) on delete cascade,
  expires_at timestamptz not null,
  used_at timestamptz
);
create index if not exists idx_claim_tokens_card on claim_tokens(card_id);

-- RLS
alter table app_users enable row level security;
alter table cards enable row level security;
alter table claim_tokens enable row level security;

create policy me_read on app_users for select using (auth.uid() = id);

create policy my_cards_read on cards for select using (owner_user_id = auth.uid());
create policy my_cards_update on cards for update using (owner_user_id = auth.uid());

create policy my_claim_tokens_read on claim_tokens
for select using (user_id = auth.uid() and used_at is null and now() < expires_at);

-- カード作成時にorg_settings.default_urlをコピーするトリガー
create or replace function set_default_url_for_new_card()
returns trigger as $$
begin
  if new.current_url is null or new.current_url = '' then
    select default_url into new.current_url 
    from org_settings 
    limit 1;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trigger_set_default_url_for_new_card
  before insert on cards
  for each row
  execute function set_default_url_for_new_card();

-- カードの更新日時を自動更新するトリガー
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trigger_update_cards_updated_at
  before update on cards
  for each row
  execute function update_updated_at_column();


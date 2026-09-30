-- Zaid Portfolio CMS - Supabase schema
create table if not exists public.portfolio_content (
  id bigint primary key generated always as identity,
  key text unique not null,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create or replace function public.touch_portfolio_content()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists portfolio_content_touch on public.portfolio_content;
create trigger portfolio_content_touch
before update on public.portfolio_content
for each row execute function public.touch_portfolio_content();

alter table public.portfolio_content enable row level security;

-- Public visitors can read published content.
drop policy if exists "public read portfolio" on public.portfolio_content;
create policy "public read portfolio"
on public.portfolio_content for select
to anon, authenticated
using (true);

-- IMPORTANT:
-- Do NOT add a public write policy.
-- Admin writes must be done only through a secured backend/authenticated path.
-- This V6 UI demonstrates the CMS contract; production write security should be
-- implemented with Supabase Auth + a protected role/RPC or server-side API.

insert into public.portfolio_content(key,value) values
('site', '{"name":"ZAID","role":"Video Editor & Motion Designer","hero":"I TRANSFORM\\nIDEAS\\nINTO VISUALS","bio":"I create cinematic edits, motion graphics and visual stories designed to make content sharper, stronger and more memorable.","stats":{"projects":"25+","clients":"10+","years":"2+","views":"50M+"}}'::jsonb)
on conflict (key) do nothing;

insert into public.portfolio_content(key,value) values
('projects', '[{"id":"p1","title":"High Energy Social Edit","category":"Short Form","description":"Editing · captions · sound design · motion","software":["Premiere Pro","After Effects"],"featured":true},{"id":"p2","title":"Product Motion Story","category":"Motion Graphics","description":"Motion · transitions · compositing","software":["After Effects"],"featured":false},{"id":"p3","title":"Creator Storytelling","category":"YouTube","description":"Hook · retention · cinematic B-roll","software":["Premiere Pro","DaVinci Resolve"],"featured":false},{"id":"p4","title":"Brand Launch Visuals","category":"Brand","description":"Editing · graphics · finishing","software":["Premiere Pro"],"featured":false}]'::jsonb)
on conflict (key) do nothing;

insert into public.portfolio_content(key,value) values
('services', '[{"id":"s1","title":"Video Editing","description":"Long-form, short-form, YouTube and social content.","visible":true},{"id":"s2","title":"Motion Graphics","description":"Titles, transitions and kinetic type.","visible":true},{"id":"s3","title":"Color & Finishing","description":"Clean color and consistent final delivery.","visible":true},{"id":"s4","title":"Sound Design","description":"Music, SFX and audio movement.","visible":true}]'::jsonb)
on conflict (key) do nothing;

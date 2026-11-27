-- Pega TODO esto en Supabase > SQL Editor > New query > Run

-- 1) Código que deben escribir los empleados para crear su cuenta (CÁMBIALO)
create table public.app_config (key text primary key, value text not null);
alter table public.app_config enable row level security;  -- sin políticas: nadie la lee desde la web
insert into public.app_config values ('codigo_registro', 'pokemon2015');

-- 2) Perfiles de empleados
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

create or replace function public.is_admin() returns boolean
language sql security definer set search_path = public stable as
$$ select coalesce((select is_admin from public.profiles where id = auth.uid()), false) $$;

-- 3) Al registrarse: valida el código y crea el perfil
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if coalesce(new.raw_user_meta_data->>'codigo','') <> (select value from public.app_config where key = 'codigo_registro') then
    raise exception 'Código de registro inválido';
  end if;
  insert into public.profiles (id, nombre)
  values (new.id, coalesce(nullif(trim(new.raw_user_meta_data->>'nombre'),''), split_part(new.email,'@',1)));
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4) Referidos
create table public.referidos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  nombre text not null,
  telefono text not null,
  correo text not null,
  fecha_referido date not null,
  resultado text not null default 'pendiente' check (resultado in ('pendiente','quedo','rechazado')),
  created_at timestamptz not null default now()
);
alter table public.referidos enable row level security;

-- 5) Seguridad: cada empleado solo ve lo suyo; el admin ve todo
create policy "perfil propio o admin" on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy "ver referidos" on public.referidos for select using (user_id = auth.uid() or public.is_admin());
create policy "crear referidos" on public.referidos for insert with check (user_id = auth.uid());
create policy "editar referidos" on public.referidos for update
  using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy "borrar referidos" on public.referidos for delete using (user_id = auth.uid() or public.is_admin());


-- 5b) Permisos de la API (por si "Grant API access to new tables automatically" estaba desactivado)
grant usage on schema public to anon, authenticated;
grant select on public.profiles to authenticated;
grant select, insert, update, delete on public.referidos to authenticated;

-- 6) Hazte administrador DESPUÉS de crear tu cuenta en la página (cambia el correo y ejecútalo solo):
-- update public.profiles set is_admin = true where id = (select id from auth.users where email = 'TU_CORREO@ejemplo.com');

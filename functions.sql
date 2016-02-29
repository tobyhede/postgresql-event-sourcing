
drop function if exists fn_project_user_insert(uuid uuid, body jsonb);
create or replace function fn_project_user_create(uuid uuid, body jsonb) returns integer
  security definer
  language plpgsql as $$
  declare result int;
  begin
    -- if event.type = 'create_user' then
    insert into users(uuid, name, inserted_at, updated_at)
      values(uuid, body->>'name', NOW(), NOW())
      returning id into result;
   return result;
  end;
$$;

drop function if exists fn_project_user_update(uuid uuid, body jsonb);
create or replace function fn_project_user_update(uuid uuid, body jsonb) returns void
  security definer
  language plpgsql as $$
  begin
    update users SET name = body->>'name', updated_at = NOW()
      where users.uuid = fn_event_user_update.uuid;
  end;
$$;

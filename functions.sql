
drop function if exists fn_project_user_insert(uuid uuid, body jsonb);
create or replace function fn_project_user_create(uuid uuid, body jsonb) returns integer as $$
  declare result int;
  begin
    insert into users(uuid, name, inserted_at, updated_at)
    values(uuid, body->>'name', NOW(), NOW())
    returning id into result;
   return result;
  end;
$$ language plpgsql security definer;

drop function if exists fn_project_user_update(uuid uuid, body jsonb);
create or replace function fn_project_user_update(uuid uuid, body jsonb) returns void as $$
  begin
    update users SET name = body->>'name', updated_at = NOW()
      where users.uuid = fn_project_user_update.uuid;
  end;
$$ language plpgsql security definer;

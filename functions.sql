
create or replace function fn_event_user_insert(id uuid, body jsonb) returns integer
  security definer
  language plpgsql
as $$
  declare result int;
  begin
   insert into users(uuid, name, inserted_at, updated_at)
      values(id, body->>'name', NOW(), NOW())
      returning id into result;
   return result;
  end;
$$;

create or replace function fn_event_user_update(id uuid, body jsonb) returns void
  security definer
  language plpgsql
as $$
  begin
    update users SET name = body->>'name', updated_at = NOW()
      where users.uuid = id;
  end;
$$;

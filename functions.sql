
create or replace function fn_event_user_insert(event jsonb) returns integer
  security definer
  language plpgsql
as $$
  declare result int;
  begin
   insert into users(id, name, inserted_at, updated_at)
      values((event->>'id')::int, event->>'name', NOW(), NOW())
      returning id into result;
   return result;
  end;
$$;

create or replace function fn_event_user_update(event jsonb) returns integer
  security definer
  language plpgsql
as $$
  begin
    update users SET name = event->>'name', updated_at = NOW()
      where users.id = (event->>'id')::int;
    return (event->>'id')::int;
  end;
$$;

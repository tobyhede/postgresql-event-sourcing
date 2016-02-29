--
-- create or replace function fn_event_user_insert_record(type text, id uuid, body jsonb) returns integer
--   security definer
--   language plpgsql
-- as $$
--   declare result int;
--   begin
--     if event.type = 'create_user' then
--      insert into users(uuid, name, inserted_at, updated_at)
--         values(event.uuid, body->>'name', NOW(), NOW())
--         returning id into result;
--     end if;
--    return result;
--   end;
-- $$;


create or replace function fn_event_user_insert(id uuid, body jsonb) returns integer
  security definer
  language plpgsql
as $$
  declare result int;
  begin
  --     if event.type = 'create_user' then
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

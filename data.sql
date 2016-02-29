
truncate table events;

truncate table users;

insert into events (type, body)
  values ('create_user', '{"id": 42, "name": "blah"}');

insert into events (type, body)
  values ('update_user', '{"id": 42, "name": "vtha"}');


-- Retrigger events
do language plpgsql $$
  declare
    e record;
  begin
    for e in select body from events where type = 'create_user' order by inserted_at asc loop
      perform fn_event_user_insert(e.body);
    end loop;
  end;
$$;


-- insert into users(id, name, inserted_at, updated_at)
--     values(new.id, new.body->>'blah', now(), now())
--   on conflict (id) do
--     update set name = new.body->>'blah', updated_at = now()
--     where users.id = new.id;

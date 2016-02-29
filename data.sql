
drop sequence IF EXISTS users_id_seq ;

create sequence users_id_seq;

drop table if exists users;

CREATE TABLE "users" (
  "id" int4 NOT NULL DEFAULT nextval('users_id_seq'::regclass),
  "uuid" uuid NOT NULL,
  "name" text NOT NULL,
  "inserted_at" timestamp(6) NOT NULL DEFAULT 'NOW()',
  "updated_at" timestamp(6) NOT NULL DEFAULT 'NOW()'
);


insert into events (type, uuid, body)
  values ('create_user', '11111111-1111-1111-1111-111111111111', '{"name": "blah"}');

insert into events (type, uuid, body)
  values ('update_user', '11111111-1111-1111-1111-111111111111', '{"name": "vtha"}');


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


truncate table users;
do language plpgsql $$
  declare
    e record;
  begin
    for e in select type, uuid, body from events where uuid = '11111111-1111-1111-1111-111111111111' order by inserted_at asc loop
	  if e.type = 'create_user' then
        perform fn_event_user_insert(e.uuid, e.body);
	  end if;
	  if e.type = 'update_user' then
        perform fn_event_user_update(e.uuid, e.body);
	  end if;
    end loop;
  end;
$$;

-- insert into users(id, name, inserted_at, updated_at)
--     values(new.id, new.body->>'blah', now(), now())
--   on conflict (id) do
--     update set name = new.body->>'blah', updated_at = now()
--     where users.id = new.id;

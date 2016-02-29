drop table if exists "users";

CREATE TABLE "users" (
  "id" serial primary key not null,
  "uuid" uuid NOT NULL,
  "name" text NOT NULL,
  "inserted_at" timestamp(6) NOT NULL DEFAULT 'NOW()',
  "updated_at" timestamp(6) NOT NULL DEFAULT 'NOW()'
);

CREATE UNIQUE INDEX "users_uuid_index" ON "users" USING btree(uuid);

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


truncate table users;
do language plpgsql $$
  declare
    e record;
  begin
    for e in select type, uuid, body from events where uuid = '11111111-1111-1111-1111-111111111111' order by inserted_at asc loop
    case e.type
      when 'create_user' then
        perform fn_event_user_insert(e.uuid, e.body);
	   when 'update_user' then
        perform fn_event_user_update(e.uuid, e.body);
	  end case;
    end loop;
  end;
$$;

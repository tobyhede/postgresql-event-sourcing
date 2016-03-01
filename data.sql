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
  values ('user_create', '11111111-1111-1111-1111-111111111111', '{"name": "blah"}');

insert into events (type, uuid, body)
  values ('user_update', '11111111-1111-1111-1111-111111111111', '{"name": "vtha"}');


-- Retrigger events
do language plpgsql $$
  declare
    e record;
  begin
    for e in select uuid, body from events where type = 'user_create' order by inserted_at asc loop
      perform fn_project_user_create(e.uuid, e.body);
    end loop;
  end;
$$;


truncate table users;
do language plpgsql $$
  declare
    e record;
  begin
    for e in select type, uuid, body from events where uuid = '11111111-1111-1111-1111-111111111111' order by inserted_at asc loop
	  if e.type = 'user_create' then
        perform fn_project_user_create(e.uuid, e.body);
	  end if;
	  if e.type = 'user_update' then
        perform fn_project_user_update(e.uuid, e.body);
	  end if;
    end loop;
  end;
$$;


drop materialized view if exists "users_view";

create materialized view users_view as
  with t as (
      select *, row_number() over(partition by uuid order by inserted_at desc) as row_number
      from events
      where type = 'update_user'
  )
  select uuid, body->>'name' as name, inserted_at from t where row_number = 1;

select * from users_view;

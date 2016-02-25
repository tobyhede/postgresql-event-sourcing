create or replace function fn_event_insert() returns trigger
  security definer
  language plpgsql
as $$
  begin
	if new.body ?& array['blah'] then
		insert into users(id, name, inserted_at, updated_at)
		  values(new.id, new.body->>'blah', NOW(), NOW())
		on conflict (id) do
			update SET name = new.body->>'blah', updated_at = NOW()
			where users.id = new.id;
	end if;
	return new;
  end;
$$;

drop trigger if exists event_insert ON events;
create trigger event_insert after insert on events
    for each row execute procedure fn_event_insert();

drop trigger if exists event_update ON events;
create trigger event_update after update on events
    for each row execute procedure fn_event_insert();


DO LANGUAGE plpgsql $$
	DECLARE
		e RECORD;
    BEGIN
		FOR e IN SELECT * FROM events LOOP
			UPDATE events SET id = e.id WHERE id = e.id;
		END LOOP;
	END;
$$;



insert into users(id, name, inserted_at, updated_at)
    values(new.id, new.body->>'blah', NOW(), NOW())
  on conflict (id) do
    update SET name = new.body->>'blah', updated_at = NOW()
    where users.id = new.id;

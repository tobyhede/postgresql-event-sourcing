
TRUNCATE TABLE events;

TRUNCATE TABLE users;

INSERT INTO events (type, body)
  VALUES ('create_user', '{"id": 42, "name": "blah"}');

INSERT INTO events (type, body)
  VALUES ('update_user', '{"id": 42, "name": "vtha"}');



TRUNCATE TABLE users;
DO LANGUAGE plpgsql $$
	DECLARE
		e RECORD;
    BEGIN
		FOR e IN SELECT body FROM events WHERE type == 'create_user' ORDER BY inserted_at ASC LOOP
      PERFORM fn_event_insert_action(e.body);
		END LOOP;
	END;
$$;



insert into users(id, name, inserted_at, updated_at)
    values(new.id, new.body->>'blah', NOW(), NOW())
  on conflict (id) do
    update SET name = new.body->>'blah', updated_at = NOW()
    where users.id = new.id;

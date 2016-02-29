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

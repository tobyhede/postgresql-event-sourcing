
create or replace function fn_event_trigger_user_create() returns trigger
  security definer
  language plpgsql
as $$
  begin
    perform fn_event_user_insert(new.uuid, new.body);
    return new;
  end;
$$;

create or replace function fn_event_trigger_user_update() returns trigger
  security definer
  language plpgsql
as $$
  begin
    perform fn_event_user_update(new.uuid, new.body);
    return new;
  end;
$$;

drop trigger if exists event_insert_create_user ON events;
create trigger event_insert_create_user after insert on events
  for each row
  when (new.type = 'create_user')
  execute procedure fn_event_trigger_user_create();

drop trigger if exists event_trigger_user_update ON events;
create trigger event_insert_update_user after insert on events
  for each row
  when (new.type = 'update_user')
  execute procedure fn_event_trigger_user_update();

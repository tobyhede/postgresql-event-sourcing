
create or replace function fn_trigger_user_create() returns trigger
  security definer
  language plpgsql
as $$
  begin
    perform fn_project_user_create(new.uuid, new.body);
    return new;
  end;
$$;

create or replace function fn_trigger_user_update() returns trigger
  security definer
  language plpgsql
as $$
  begin
    perform fn_project_user_update(new.uuid, new.body);
    return new;
  end;
$$;

drop trigger if exists event_insert_user_create ON events;
create trigger event_insert_user_create after insert on events
  for each row
  when (new.type = 'user_create')
  execute procedure fn_trigger_user_insert();

drop trigger if exists event_insert_user_update ON events;
create trigger event_insert_user_update after insert on events
  for each row
  when (new.type = 'user_update')
  execute procedure fn_trigger_user_update();

create or replace function fn_trigger_reject_update_or_delete() returns trigger as $$
  begin
     RETURN NULL;
  end;
$$ language plpgsql security definer;

drop trigger if exists event_reject_update_or_delete ON events;
create trigger event_reject_update_or_delete before update or delete on events
  for each row
  execute procedure fn_trigger_reject_update_or_delete();

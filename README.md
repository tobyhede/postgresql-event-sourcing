# postgresql-event-sourcing

Experiment using PostgreSQL as a natively event sourcing database.  

Uses triggers and functions to manage projections transactionally.

The basic flow of action is:

event -> after insert trigger -> trigger function -> projection function -> projection

The advantage of this model is that triggers ensure the projections are always up to date, but we do not lose the abilty to replay the event stream with the same logic.


### Events

Event Sourcing ensures that all changes to application state are stored as a sequence of events.

Events are stored in an `events` table.

We assume that all objects/entities in the system have a globally unique identifier.

| Column  | Details                 |
|---------|-------------------------|
| id      | Primary Key  |
| uuid    | Unique ID of the entity the event references  |
| type    | The event type, used when building projections  |
| body    | Event data as JSON  |
| inserted_at    | timestamp of event insert  |

=======
postgresql event sourcing



### Events Table




>>>>>>> reviewed names based on readme work
```sql
CREATE TABLE "events" (
  "id" serial primary key not null,
  "uuid" uuid NOT NULL,
  "type" text NOT NULL,
  "body" jsonb NOT NULL,
  "inserted_at" timestamp(6) NOT NULL DEFAULT 'NOW()'
);
```

<<<<<<< 4093f3946313f48e38c518757ade1f5a3d33f536
An example event, tracking an update to the name of the user identifier by the uuuid:

```sql
insert into events (type, uuid, body)
values ('user_create', '11111111-1111-1111-1111-111111111111', '{"name": "blah"}');
```

### Projection Triggers

Use `after insert` triggers on the `events` table to handle the incoming event actions.

In order to replay the events outside of the trigger mechanism, we wrap a general projection function inside the trigger. This will make more sense in a moment.

Below we create a trigger function and a trigger to execute.
The trigger uses a conditional to only fire when the appropriate event type has been inserted.

```sql
create or replace function fn_trigger_user_create() returns trigger
  security definer
  language plpgsql
as $$
  begin
    perform fn_project_user_create(new.uuid, new.body);
    return new;
  end;
$$;

create trigger event_insert_user_create after insert on events
  for each row
  when (new.type = 'user_create')
  execute procedure fn_trigger_user_insert();
```

### Projection Functions

A projection function does the actual work of handling the event data and mapping to the appropriote projection.
Multiple triggers and multiple functions can be added to handle different aspects of the same event type if required.

Assuming a `users` table with a `name` and `uuid`, the following function inserts a new user record into the table based on the `user_create` event.

```sql
create or replace function fn_project_user_create(uuid uuid, body jsonb) returns integer
  security definer
  language plpgsql as $$
  declare result int;
  begin
    insert into users(uuid, name, inserted_at, updated_at)
      values(uuid, body->>'name', NOW(), NOW())
      returning id into result;
    return result;
  end;
$$;
```

JSON can be referenced using the native operators in PostgreSQL 9.5. `body->>'name'` extracts the value of the name field from the body JSON.

Any constraints on the table will also be enforced, ensuring referential integrity.


### Replay Event Stream

Using projection functions means that at any point the events can be replayed, simply by calling the function and passing the correct identifier and data.


The following code replays all `user_create` events in order

```sql
do language plpgsql $$
  declare
    e record;
  begin
    for e in select uuid body from events where type = 'user_create' order by inserted_at asc loop
      perform fn_project_user_create(e.uuid, e.body);
    end loop;
  end;
$$;
```

Any valid query can be used as the basis for the replay loop, and any combination of valid events.

The following code replays all events for the user identified by the specified uuid:

```sql
do language plpgsql $$
  declare
    e record;
  begin
    for e in select type, uuid, body from events where uuid = '11111111-1111-1111-1111-111111111111' order by inserted_at asc loop
    case e.type
      when 'user_create' then
        perform fn_project_user_create(e.uuid, e.body);
	   when 'user_update' then
        perform fn_project_user_update(e.uuid, e.body);
	  end case;
    end loop;
  end;
$$;
```

All of these functions will be executed in the same transaction block.
This doesn't particularly matter in an event sourced system, but it is good to know.

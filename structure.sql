DROP TABLE IF EXISTS "events";

CREATE TABLE "events" (
  id serial primary key not null,
  "uuid" uuid NOT NULL,
  "type" text NOT NULL,
  "partition" int4 NOT NULL DEFAULT 0,
  "body" jsonb NOT NULL,
  "inserted_at" timestamp(6) NOT NULL DEFAULT 'NOW()'
);

CREATE INDEX "events_type" ON "events" USING btree(type ASC);

CREATE INDEX "events_uuid" ON "events" USING btree(uuid);

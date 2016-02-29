DROP TABLE IF EXISTS "events";

CREATE TABLE "events" (
  "id" serial primary key not null,
  "uuid" uuid NOT NULL,
  "type" text NOT NULL,
  "body" jsonb NOT NULL,
  "inserted_at" timestamp(6) NOT NULL DEFAULT 'NOW()'
);

CREATE INDEX "events_type" ON "events" USING btree(type ASC);

CREATE INDEX "events_uuid" ON "events" USING btree(uuid);

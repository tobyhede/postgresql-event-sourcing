DROP TABLE IF EXISTS "events";

CREATE TABLE "events" (
  "id" serial primary key not null,
  "uuid" uuid NOT NULL,
  "type" text NOT NULL,
  "body" jsonb NOT NULL,
  "inserted_at" timestamp(6) NOT NULL DEFAULT statement_timestamp()
);

CREATE INDEX "idx_events_type" ON "events" (type ASC);

CREATE INDEX "idx_events_uuid" ON "events" (uuid);

CREATE INDEX "idx_events_inserted_at" ON "events" (inserted_at DESC);

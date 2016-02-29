DROP TABLE IF EXISTS "events";

DROP SEQUENCE IF EXISTS events_id_seq ;

CREATE SEQUENCE events_id_seq;

CREATE TABLE "events" (
  "id" int4 NOT NULL DEFAULT nextval('events_id_seq'::regclass),
  "uuid" uuid NOT NULL,
  "type" text NOT NULL,
  "partition" int4 NOT NULL DEFAULT 0,
  "body" jsonb NOT NULL,
  "inserted_at" timestamp(6) NOT NULL DEFAULT 'NOW()'
);

ALTER TABLE "events" ADD CONSTRAINT "events_pkey" PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- CREATE INDEX "events_body_id" ON "events" USING btree((body ->> 'id'::text) ASC NULLS LAST);

CREATE INDEX "events_type" ON "events" USING btree(type ASC);

CREATE INDEX "events_uuid" ON "events" USING btree(uuid);

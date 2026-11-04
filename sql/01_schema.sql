-- Schema for the claims rule engine (PostgreSQL 13+)
-- A claim is one patient seen by one provider on one date. It can carry several CPT codes.

DROP TABLE IF EXISTS claims, claims_raw, providers CASCADE;
DROP FUNCTION IF EXISTS cpt_text_to_jsonb(text);

CREATE TABLE providers (
    provider_name text PRIMARY KEY,
    specialty     text NOT NULL
);

-- Landing table: claims exactly as exported, with CPT codes as text such as {97110,97140}
CREATE TABLE claims_raw (
    patient_name    text,
    provider_name   text,
    from_date_range date,
    cpt_codes       text
);

-- Typed table the rules run against: one row per claim, CPT codes as a JSONB array
CREATE TABLE claims (
    claim_id        serial PRIMARY KEY,
    patient_name    text  NOT NULL,
    provider_name   text  NOT NULL REFERENCES providers (provider_name),
    from_date_range date  NOT NULL,
    cpt_codes       jsonb NOT NULL CHECK (jsonb_typeof(cpt_codes) = 'array'),
    UNIQUE (patient_name, provider_name, from_date_range)
);

-- GIN index so "does this claim contain code X" (@>) stays fast as the table grows
CREATE INDEX claims_cpt_codes_gin ON claims USING gin (cpt_codes);

-- Converts the exported text format {97110,97140} to the JSONB array [97110,97140].
-- Using it in the load step means new files are ready for the rules without manual fixes.
CREATE FUNCTION cpt_text_to_jsonb(raw text)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT replace(replace(trim(raw), '{', '['), '}', ']')::jsonb
$$;

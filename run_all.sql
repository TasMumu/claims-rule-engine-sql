-- Build the schema, load the sample data and run all three rules.
-- Usage: psql -d <database> -f run_all.sql   (run from the repository folder)

\set ON_ERROR_STOP on
\i sql/01_schema.sql
\i sql/02_sample_data.sql

\echo
\echo 'Rule 1: Specialist code omission for frequent patients'
\i sql/rule_1_frequent_patient_code_omission.sql

\echo 'Rule 2: Multi-provider overlap on CPT 97010 within one month'
\i sql/rule_2_multi_provider_overlap.sql

\echo 'Rule 3: Provider-specific CPT code deviation in Physical Therapy'
\i sql/rule_3_provider_code_deviation.sql

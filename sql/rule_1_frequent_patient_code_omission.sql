-- Rule 1: Specialist code omission for frequent patients
-- Flags an Occupational Therapy or Chiropractic claim that does not include CPT 97140,
-- when the patient has more than 5 claims in total with any provider.

WITH claims_per_patient AS (
    -- A claim is identified by patient, provider and date, so count those combinations.
    -- This stays correct even if a source file splits one claim over several rows.
    SELECT patient_name,
           COUNT(DISTINCT (provider_name, from_date_range)) AS total_claims
    FROM claims
    GROUP BY patient_name
)
SELECT c.patient_name,
       c.provider_name,
       c.from_date_range
FROM claims c
JOIN providers p
  ON p.provider_name = c.provider_name
JOIN claims_per_patient cp
  ON cp.patient_name = c.patient_name
WHERE p.specialty IN ('Occupational Therapy', 'Chiropractic')
  AND NOT c.cpt_codes @> '[97140]'
  AND cp.total_claims > 5
ORDER BY c.patient_name, c.from_date_range;

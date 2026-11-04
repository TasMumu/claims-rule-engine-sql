-- Rule 2: Multi-provider overlap on CPT 97010 within one calendar month
-- Flags claims when, in the same month, at least 2 different providers billed the same patient,
-- and every claim from each of those providers that month includes 97010 and none includes 97014.

WITH claim_months AS (
    SELECT patient_name,
           provider_name,
           from_date_range,
           date_trunc('month', from_date_range)::date AS claim_month,
           cpt_codes
    FROM claims
),
qualifying_providers AS (
    -- One row per patient, provider and month where the provider's claims
    -- all contain 97010 and none contain 97014
    SELECT patient_name, provider_name, claim_month
    FROM claim_months
    GROUP BY patient_name, provider_name, claim_month
    HAVING bool_and(cpt_codes @> '[97010]')
       AND NOT bool_or(cpt_codes @> '[97014]')
),
flagged_patient_months AS (
    -- Patient-months where at least 2 distinct providers qualify
    SELECT patient_name, claim_month
    FROM qualifying_providers
    GROUP BY patient_name, claim_month
    HAVING COUNT(DISTINCT provider_name) >= 2
)
-- Return the claims behind each flag. Claims from other providers that month
-- who did not meet the CPT conditions are left out.
SELECT cm.patient_name,
       cm.provider_name,
       cm.from_date_range
FROM claim_months cm
JOIN qualifying_providers qp
  USING (patient_name, provider_name, claim_month)
JOIN flagged_patient_months fpm
  USING (patient_name, claim_month)
ORDER BY cm.patient_name, cm.from_date_range;

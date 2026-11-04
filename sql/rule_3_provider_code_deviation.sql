-- Rule 3: Provider-specific CPT code deviation within Physical Therapy
-- Flags a Physical Therapy claim that has CPT 97010 but not 97110,
-- when the same provider has billed 97110 on at least one other claim (any patient, any date).

SELECT c.patient_name,
       c.provider_name,
       c.from_date_range
FROM claims c
JOIN providers p
  ON p.provider_name = c.provider_name
WHERE p.specialty = 'Physical Therapy'
  AND c.cpt_codes @> '[97010]'
  AND NOT c.cpt_codes @> '[97110]'
  AND EXISTS (
        -- Any claim from this provider with 97110 is necessarily a different claim,
        -- because the flagged claim has no 97110. No date filter is needed, so a
        -- 97110 claim on the same day for another patient still counts.
        SELECT 1
        FROM claims other
        WHERE other.provider_name = c.provider_name
          AND other.cpt_codes @> '[97110]'
      )
ORDER BY c.patient_name, c.from_date_range;

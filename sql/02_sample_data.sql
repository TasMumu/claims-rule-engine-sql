-- Synthetic sample data: invented patients and providers, built so each rule has cases that should and should not trigger.
-- The same rows are in data/providers.csv and data/claims.csv.

INSERT INTO providers (provider_name, specialty) VALUES
  ('Maya Brooks', 'Physical Therapy'),
  ('Owen Patel', 'Physical Therapy'),
  ('Grace Lin', 'Physical Therapy'),
  ('Iris Novak', 'Physical Therapy'),
  ('Ruth Okafor', 'Chiropractic'),
  ('Daniel Reyes', 'Occupational Therapy');

-- CPT codes arrive as text in the source format, e.g. {97110,97140}
INSERT INTO claims_raw (patient_name, provider_name, from_date_range, cpt_codes) VALUES
  ('Nora Ellis', 'Ruth Okafor', DATE '2024-07-02', '{98940,97140}'),
  ('Nora Ellis', 'Maya Brooks', DATE '2024-07-05', '{97110,97140}'),
  ('Nora Ellis', 'Daniel Reyes', DATE '2024-07-09', '{97530,97112}'),
  ('Nora Ellis', 'Ruth Okafor', DATE '2024-07-16', '{98940,97010}'),
  ('Nora Ellis', 'Maya Brooks', DATE '2024-08-06', '{97010,97110}'),
  ('Nora Ellis', 'Owen Patel', DATE '2024-08-13', '{97110,97112}'),
  ('Nora Ellis', 'Owen Patel', DATE '2024-09-03', '{97010,97014}'),
  ('Felix Grant', 'Ruth Okafor', DATE '2024-07-10', '{98940}'),
  ('Felix Grant', 'Daniel Reyes', DATE '2024-07-24', '{97530}'),
  ('Felix Grant', 'Maya Brooks', DATE '2024-08-01', '{97110}'),
  ('Felix Grant', 'Iris Novak', DATE '2024-09-12', '{97010}'),
  ('Ivy Moreno', 'Maya Brooks', DATE '2024-08-05', '{97010,97110}'),
  ('Ivy Moreno', 'Owen Patel', DATE '2024-08-12', '{97010,97140}'),
  ('Ivy Moreno', 'Maya Brooks', DATE '2024-08-19', '{97010,97112}'),
  ('Ivy Moreno', 'Grace Lin', DATE '2024-08-22', '{97010,97014}'),
  ('Leo Hart', 'Maya Brooks', DATE '2024-09-04', '{97010,97110}'),
  ('Leo Hart', 'Owen Patel', DATE '2024-09-11', '{97010,97014,97110}'),
  ('Leo Hart', 'Iris Novak', DATE '2024-09-12', '{97110,97112}'),
  ('Leo Hart', 'Maya Brooks', DATE '2024-09-18', '{97110,97140}'),
  ('Clara Webb', 'Grace Lin', DATE '2024-07-08', '{97010,97112}'),
  ('Clara Webb', 'Owen Patel', DATE '2024-07-15', '{97010,97110}'),
  ('Clara Webb', 'Daniel Reyes', DATE '2024-07-22', '{97530}'),
  ('Clara Webb', 'Owen Patel', DATE '2024-07-29', '{97010}'),
  ('Hugo Diaz', 'Ruth Okafor', DATE '2024-08-02', '{98940,97140}'),
  ('Hugo Diaz', 'Ruth Okafor', DATE '2024-08-09', '{98940,97140}'),
  ('Hugo Diaz', 'Daniel Reyes', DATE '2024-08-14', '{97530,97140}'),
  ('Hugo Diaz', 'Ruth Okafor', DATE '2024-08-23', '{98940,97010}'),
  ('Hugo Diaz', 'Grace Lin', DATE '2024-09-05', '{97010,97112}'),
  ('Hugo Diaz', 'Maya Brooks', DATE '2024-09-12', '{97010,97112}');

-- Load into the typed table, converting the codes to a JSONB array on the way in
INSERT INTO claims (patient_name, provider_name, from_date_range, cpt_codes)
SELECT patient_name, provider_name, from_date_range, cpt_text_to_jsonb(cpt_codes)
FROM claims_raw;

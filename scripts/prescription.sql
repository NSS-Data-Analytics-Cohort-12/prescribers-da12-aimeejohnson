-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi
ORDER BY total_claims DESC
LIMIT 1;

-- 1881634483, 99707

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT CONCAT(nppes_provider_first_name,' ',nppes_provider_last_org_name) AS full_name, specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY full_name,specialty_description
ORDER BY total_claims DESC
LIMIT 1;

-- "BRUCE PENDLEY"	"Family Practice" 99707

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description,SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY total_claims DESC;

-- "Family Practice"	9752347

--     b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
	USING(npi)
INNER JOIN drug
	USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_claims DESC;

--"Nurse Practitioner"	900845

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost) AS total_cost
FROM prescription
INNER JOIN drug
	USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC;

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, ROUND(SUM(Total_drug_cost)/SUM(total_day_supply),2) AS cost_per_day
FROM prescription
INNER JOIN drug
	USING (drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC
LIMIT 1;

--"CINRYZE"	3495.22

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
SELECT drug_name,
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT SUM(total_drug_cost) :: Money AS total_cost, 
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;

--Opioids

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%TN';

-- 33
--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, SUM(population) AS total_population
FROM cbsa
INNER JOIN population
USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC;

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county, population
FROM fips_county
INNER JOIN population
USING (fipscounty)
FULL JOIN cbsa
USING (fipscounty)
WHERE cbsa IS NULL
ORDER BY population DESC;

--"SEVIER"	95523

-- 6.
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
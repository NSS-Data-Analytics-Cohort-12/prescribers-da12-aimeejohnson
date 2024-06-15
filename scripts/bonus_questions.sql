-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT COUNT(*)
FROM(
	SELECT npi
	FROM prescriber
	EXCEPT
	SELECT npi
	FROM prescription
) as not_prescription;

SELECT COUNT(prescriber.npi)
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE prescription.npi IS NULL;

-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT drug.generic_name,SUM(prescription.total_claim_count) as total_count
FROM prescriber
INNER JOIN prescription
	USING (npi)
INNER JOIN drug
	USING (drug_name)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY total_count DESC
LIMIT 5;

--"LEVOTHYROXINE SODIUM"	406547
--"LISINOPRIL"	311506
--"ATORVASTATIN CALCIUM"	308523
--"AMLODIPINE BESYLATE"	304343
--"OMEPRAZOLE"	273570

--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT dp.generic_name,SUM(dp.total_claim_count) AS total_claims
FROM prescriber
INNER JOIN(
	SELECT *
	FROM prescription
	INNER JOIN drug
		USING (drug_name)
) AS dp ON prescriber.npi = dp.npi
WHERE specialty_description = 'Cardiology'
GROUP BY dp.generic_name
ORDER BY total_claims DESC
LIMIT 5;

--"ATORVASTATIN CALCIUM"	120662
--"CARVEDILOL"	106812
--"METOPROLOL TARTRATE"	93940
--"CLOPIDOGREL BISULFATE"	87025
--"AMLODIPINE BESYLATE"	86928

--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.
SELECT dp.generic_name,SUM(dp.total_claim_count) AS total_claims
FROM prescriber
INNER JOIN(
	SELECT *
	FROM prescription
	INNER JOIN drug
		USING (drug_name)
) AS dp ON prescriber.npi = dp.npi
WHERE specialty_description = 'Cardiology'
	OR specialty_description = 'Family Practice'
GROUP BY dp.generic_name
ORDER BY total_claims DESC
LIMIT 5;

--"ATORVASTATIN CALCIUM"	429185
--"LEVOTHYROXINE SODIUM"	415476
--"AMLODIPINE BESYLATE"	391271
--"LISINOPRIL"	387799
--"FUROSEMIDE"	318196

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
SELECT prescriber.npi, prescription.total_claim_count, prescriber.nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
ORDER BY total_claim_count DESC;

SELECT prescriber.npi, SUM(prescription.total_claim_count) as total_claims, prescriber.nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY prescriber.npi,prescriber.nppes_provider_city 
ORDER BY total_claims DESC;

--     b. Now, report the same for Memphis.
SELECT prescriber.npi, prescription.total_claim_count, prescriber.nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
ORDER BY total_claim_count DESC;

SELECT prescriber.npi, SUM(prescription.total_claim_count) as total_claims, prescriber.nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY prescriber.npi,prescriber.nppes_provider_city 
ORDER BY total_claims DESC;
    
--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.
SELECT prescriber.npi, prescription.total_claim_count, prescriber.nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city IN ('NASHVILLE,''MEMPHIS', 'KNOXVILLE', 'CHATTANOOGA')
ORDER BY total_claim_count DESC;

SELECT prescriber.npi, SUM(prescription.total_claim_count) as total_claims, prescriber.nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city IN ('NASHVILLE,''MEMPHIS', 'KNOXVILLE', 'CHATTANOOGA')
GROUP BY prescriber.npi,prescriber.nppes_provider_city 
ORDER BY total_claims DESC;

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

-- SELECT fipscounty, AVG(o.overdose_deaths) AS avg_overdose_deaths
-- FROM overdose_deaths o
-- GROUP BY o.fipscounty;

WITH a AS(SELECT o.fipscounty, AVG(o.overdose_deaths) AS avg_overdose_deaths
FROM overdose_deaths o
GROUP BY o.fipscounty)
SELECT f.county, o.overdose_deaths
FROM overdose_deaths o
LEFT JOIN fips_county f
ON o.fipscounty = f.fipscounty::INTEGER
JOIN a
ON o.fipscounty = a.fipscounty
WHERE o.overdose_deaths > a.avg_overdose_deaths
ORDER BY overdose_deaths DESC;

-- 5.
--     a. Write a query that finds the total population of Tennessee.
SELECT f.state,SUM(p.population) as total_population
FROM population p
	INNER JOIN fips_county f
ON p.fipscounty = f.fipscounty
WHERE f.state = 'TN'
GROUP BY f.state;

--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.
WITH tn AS (
    SELECT SUM(p.population) AS total_population
    FROM population p
    INNER JOIN fips_county f
    	ON p.fipscounty = f.fipscounty
    WHERE f.state = 'TN'
)
SELECT f.county,p.population, 
    (p.population / tn.total_population) * 100 AS county_percent
FROM population p
JOIN fips_county f
USING (fipscounty)
CROSS JOIN tn
WHERE f.state = 'TN';

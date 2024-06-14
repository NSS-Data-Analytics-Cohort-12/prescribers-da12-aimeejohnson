-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT npi
FROM prescriber
EXCEPT
SELECT npi
FROM prescription;

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
    
--     b. Now, report the same for Memphis.
    
--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

-- 5.
--     a. Write a query that finds the total population of Tennessee.
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.

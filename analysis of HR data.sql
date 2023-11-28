create database human_resources;
use human_resources;
select * from hr_data;
desc hr_data;

----------------- changing format of birthdate and datatype also 
UPDATE hr_data
SET birthdate = CASE
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
        
alter table hr_data
modify birthdate date;


----------------- changing format of hire date and datatype also 
UPDATE hr_data
SET hire_date = CASE
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;

alter table hr_data
modify hire_date date;

----------------- change the date format and datatpye of termdate column
UPDATE hr_data
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

UPDATE hr_data
SET termdate = NULL
WHERE termdate = '';

alter table hr_data
modify termdate date;

----------------- creating age column 
ALTER TABLE hr_data
ADD column age INT;

UPDATE hr_data
SET age = timestampdiff(YEAR,birthdate,curdate());
select * from hr_data;

----------- Q1. genderbreak down of employees in company 
select count(*) as count,gender
from hr_data
WHERE termdate IS NULL
group by gender;

----------- Q2. race break down of employees in company 
select count(*) as count,race
from hr_data
WHERE termdate IS NULL
group by race;

-------------- Q3. Age distribution of employee in company
SELECT 
	CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
    FROM hr_data
    WHERE termdate IS NULL
    GROUP BY age_group
    ORDER BY count desc;
    
-------------- Q4.How many employees work at HQ vs remote
SELECT location, COUNT(*) AS count
FROm hr_data
WHERE termdate IS NULL
GROUP BY location;

-------------- Q5.What is the average length of employement who have been teminated.
SELECT ROUND(AVG(year(termdate) - year(hire_date)),0) AS length_of_emp
FROM hr_data
WHERE termdate IS NOT NULL AND termdate <= curdate();

-------------- Q6. How does the gender distribution vary acorss dept. and job titles

SELECT department,jobtitle,gender,COUNT(*) AS count
FROM hr_data
WHERE termdate IS NOT NULL
GROUP BY department, jobtitle,gender
ORDER BY department, jobtitle,gender;

SELECT department,gender,COUNT(*) AS count
FROM hr_data
WHERE termdate IS NOT NULL
GROUP BY department,gender
ORDER BY department,gender;

-------------- Q7. What is the distribution of jobtitles acorss the company
SELECT jobtitle, COUNT(*) AS count
FROm hr_data
WHERE termdate IS NULL
GROUP BY jobtitle 
order by jobtitle;


-------------- Q. Which dept has the higher turnover/termination rate

SELECT department, COUNT(*) AS total_count,
        COUNT(CASE
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminated_count,
		ROUND((COUNT(CASE
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
                    END)/COUNT(*))*100,2) AS termination_rate
		FROM hr_data
        GROUP BY department
        ORDER BY termination_rate DESC;

-------------- Q9.What is the distribution of employees across location_state
SELECT location_state, COUNT(*) AS count
FROm hr_data
WHERE termdate IS NULL
GROUP BY location_state;

SELECT location_city, COUNT(*) AS count
FROm hr_data
WHERE termdate IS NULL
GROUP BY location_city;


----------- Q10. How has the companys employee count changed over time based on hire and termination date.

SELECT year,hires,terminations,hires-terminations AS net_change,(terminations/hires)*100 AS change_percent
FROM(
		SELECT YEAR(hire_date) AS year,
		COUNT(*) AS hires,
		SUM(CASE 
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
		FROM hr_data
		GROUP BY YEAR(hire_date)) AS subquery
GROUP BY year
ORDER BY year; 

----------- Q11.  What is the tenure distribution for each dept.
SELECT department, round(avg(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM hr_data
WHERE termdate IS NOT NULL AND termdate<= curdate()
GROUP BY department;


----------- Q12. department distribution in company 
select count(*) as count,department
from hr_data
WHERE termdate IS NULL
group by department;


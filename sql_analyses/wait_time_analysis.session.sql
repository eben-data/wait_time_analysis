CREATE TABLE patient_time_fact(
    Patient_ID VARCHAR(50) PRIMARY KEY,
    Patient_admission_date VARCHAR(100),
    Patient_admission_time TIME,
    Patient_name VARCHAR(100),
    Patient_gender VARCHAR(50),
    Patient_age INT,
    Patient_race VARCHAR(100),
    Referral_department VARCHAR(50),
    Patient_admission_flag VARCHAR(100),
    Patient_satisfaction_score INT,
    Patient_wait_time INT
);


COPY patient_time_fact
FROM 'C:\DATA ANALYTICS\wait_time_analysis\Dataset\healthcare_analytics_patient_flow_data (1).csv'
WITH (FORMAT csv, HEADER TRUE, DELIMITER ',', ENCODING 'UTF8');

SELECT * FROM patient_time_fact;


/* This exploratory analysis would seek to answer the following questions:
1. Average wait time per referral department/Number of patients with prolonged wait time per department?
2. Average satisfaction score per referral department/Number of dissatisfied patients per department?
3. Is there a relationship between wait time and satisfaction score?
4. What time of the day is associated with longer wait time?
5. What months of the year are associated with longer wait time and poorer satisfaction scores?
*/

--1. What is the average wait time by department?
SELECT
    Referral_department,
    ROUND(AVG(Patient_wait_time), 2) AS avg_wait_time
FROM
    patient_time_fact
WHERE
    Referral_department <> 'None'
GROUP BY
    Referral_department
ORDER BY avg_wait_time DESC;



-- 1b Number of patients with wait time >= 50 by departmet
SELECT
    COUNT(patient_id) AS number_of_patients,
    Referral_department
FROM
    patient_time_fact
WHERE
    patient_wait_time >= 50
AND
    referral_department <> 'None'
GROUP BY referral_department
ORDER BY number_of_patients DESC;


-- 2. What departments are associated with poorer satisfaction scores?
SELECT
    Referral_department,
    ROUND(AVG(Patient_satisfaction_score), 2) AS avg_satisfaction_score
FROM
    patient_time_fact
WHERE 
    patient_satisfaction_score IS NOT NULL
AND
    referral_department <> 'None'
GROUP BY referral_department
ORDER BY avg_satisfaction_score ASC;


-- 2b Number of patients with satisfaction score <= 3 per department

SELECT
    COUNT(Patient_ID) AS patient_number,
    Referral_department
FROM
    patient_time_fact
WHERE 
    patient_satisfaction_score IS NOT NULL
AND
patient_satisfaction_score <= 3
AND
    referral_department <> 'None'
GROUP BY referral_department
ORDER BY patient_number DESC;


--3. Is there a correlation between wait time and satisfaction scores for each department?

SELECT
    Referral_department,
    ROUND(AVG(Patient_wait_time), 2) AS avg_wait_time,
    ROUND(AVG(Patient_satisfaction_score), 2) AS avg_patient_satisfaction_score
FROM
    patient_time_fact
WHERE
    referral_department <> 'None'
GROUP BY referral_department;

-- 3a. Relationship with poor satisfaction scores alone

SELECT
    Referral_department,
    COUNT(Patient_ID) AS patient_per_referral_dept
FROM
    patient_time_fact
WHERE
    referral_department <> 'None'
AND
    patient_satisfaction_score <= 3
GROUP BY referral_department
ORDER BY patient_per_referral_dept DESC;

-- 3b Relationship with extended wait time alone

SELECT
    Referral_department,
    COUNT(Patient_ID) AS patient_per_referral_dept
FROM
    patient_time_fact
WHERE
    referral_department <> 'None'
AND
    patient_wait_time >= 50
GROUP BY referral_department
ORDER BY patient_per_referral_dept DESC;



-- 4. What time of the day is associated with longer wait time?

ALTER TABLE patient_time_fact
ADD COLUMN patient_admission_hour INT;

UPDATE patient_time_fact
SET patient_admission_hour =
    EXTRACT(
        HOUR FROM patient_admission_time
    );

-- 4a. Using Night and Day shift flags

SELECT
    CASE
        WHEN patient_admission_time >= '08:00:00'
         AND patient_admission_time < '16:00:00'
        THEN 'Day shift'
        ELSE 'Night shift'
    END AS shift_time,
    COUNT(patient_id) AS patient_number
FROM patient_time_fact
WHERE patient_wait_time >= 50
GROUP BY
    CASE
        WHEN patient_admission_time >= '08:00:00'
         AND patient_admission_time < '16:00:00'
        THEN 'Day shift'
        ELSE 'Night shift'
    END;




SELECT
    CASE
        WHEN patient_admission_time >= '08:00:00'
         AND patient_admission_time < '16:00:00'
        THEN 'Day shift'
        ELSE 'Night shift'
    END AS shift_time,
    COUNT(patient_id) AS patient_number
FROM patient_time_fact
WHERE patient_satisfaction_score <= 3
GROUP BY
    CASE
        WHEN patient_admission_time >= '08:00:00'
         AND patient_admission_time < '16:00:00'
        THEN 'Day shift'
        ELSE 'Night shift'
    END;

-- 4b. Using hour of the day.

SELECT
    COUNT(Patient_ID) AS patient_number,
    patient_admission_hour
FROM
    patient_time_fact
WHERE
    patient_wait_time >= 50
GROUP BY patient_admission_hour
ORDER BY patient_number DESC;



SELECT
    COUNT(Patient_ID) AS patient_number,
    patient_admission_hour
FROM
    patient_time_fact
GROUP BY patient_admission_hour
ORDER BY patient_number DESC;





--5. Is the wait time longer for admitted patients or non_admitted patients?
SELECT
    COUNT(Patient_ID) AS patient_number,
    Patient_admission_flag
FROM
    patient_time_fact
WHERE
    patient_wait_time >= 50
GROUP BY
    Patient_admission_flag;


--5b Relate to patient satisfaction score

SELECT
    COUNT(Patient_ID) AS patient_number,
    Patient_admission_flag
FROM
    patient_time_fact
WHERE
    patient_satisfaction_score <= 3
GROUP BY
    Patient_admission_flag;


-- 6. What month of the year is associated with longer wait time and poorer patient satisfaction scores?


ALTER TABLE patient_time_fact
ADD COLUMN patient_admission_month INT;

UPDATE patient_time_fact
SET patient_admission_month =
    EXTRACT(
        MONTH FROM TO_DATE(patient_admission_date, 'DD/MM/YYYY')
    );

ALTER TABLE patient_time_fact
ADD COLUMN patient_admission_year INT;

UPDATE patient_time_fact
SET patient_admission_year =
    EXTRACT(
        YEAR FROM TO_DATE(patient_admission_date, 'DD/MM/YYYY')
    );

-- 6a Relate to longer wait time

SELECT
    COUNT(Patient_ID) AS patient_number,
    Patient_admission_month
FROM
    patient_time_fact
WHERE
    patient_wait_time >= 50
GROUP BY
    Patient_admission_month
ORDER BY patient_number DESC;


--6b Relate to patient satisfaction score

SELECT
    COUNT(Patient_ID) AS patient_number,
    Patient_admission_month
FROM
    patient_time_fact
WHERE
    patient_satisfaction_score <= 3
GROUP BY
    Patient_admission_month
ORDER BY patient_number DESC;


SELECT
    COUNT(Patient_ID)
FROM
    patient_time_fact
WHERE
    patient_satisfaction_score IS NULL
GROUP BY
    Referral_department;
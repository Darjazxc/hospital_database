-- SQL Queries for Hospital Database

-- Query 1: List of available beds in Therapeutic and Surgical departments
SELECT 
    d.department_name AS "Department",
    w.ward_number AS "Ward Number",
    b.bed_number AS "Bed Number",
    bt.type_name AS "Bed Type",
    b.status AS "Status"
FROM 
    beds b
JOIN wards w ON b.ward_id = w.ward_id
JOIN departments d ON w.department_id = d.department_id
JOIN bed_types bt ON b.bed_type_id = bt.bed_type_id
WHERE 
    b.status = 'available'
    AND (d.department_name = 'Therapeutic Department' OR d.department_name = 'Surgical Department')
ORDER BY 
    d.department_name, w.ward_number, b.bed_number;


-- Query 2: List of patients to be discharged and wards with beds to be freed
SELECT 
    p.last_name || ' ' || p.first_name || ' ' || COALESCE(p.middle_name, '') AS "Patient Name",
    d.department_name AS "Department",
    w.ward_number AS "Ward Number",
    b.bed_number AS "Bed Number",
    h.admission_date::date AS "Admission Date",
    h.expected_discharge_date AS "Discharge Date",
    h.diagnosis AS "Diagnosis"
FROM 
    hospitalizations h
JOIN patients p ON h.patient_id = p.patient_id
JOIN beds b ON h.bed_id = b.bed_id
JOIN wards w ON b.ward_id = w.ward_id
JOIN departments d ON w.department_id = d.department_id
WHERE 
    h.expected_discharge_date = '2025-01-15'
    AND h.status = 'active'
ORDER BY 
    d.department_name, w.ward_number;


-- Query 3: Number of referrals by type for a given period
SELECT 
    rt.type_name AS "Referral Type",
    COUNT(r.referral_id) AS "Number of Referrals",
    MIN(r.referral_date) AS "First Referral",
    MAX(r.referral_date) AS "Last Referral"
FROM 
    referral_types rt
LEFT JOIN referrals r ON rt.referral_type_id = r.referral_type_id
    AND r.referral_date BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY 
    rt.type_name
ORDER BY 
    COUNT(r.referral_id) DESC;


-- Query 4: Department occupancy statistics
SELECT 
    d.department_name AS "Department",
    COUNT(b.bed_id) AS "Total Beds",
    SUM(CASE WHEN b.status = 'occupied' THEN 1 ELSE 0 END) AS "Occupied",
    SUM(CASE WHEN b.status = 'available' THEN 1 ELSE 0 END) AS "Available",
    ROUND(100.0 * SUM(CASE WHEN b.status = 'occupied' THEN 1 ELSE 0 END) / COUNT(b.bed_id), 1) AS "Occupancy %"
FROM 
    departments d
JOIN wards w ON d.department_id = w.department_id
JOIN beds b ON w.ward_id = b.ward_id
GROUP BY 
    d.department_name
ORDER BY 
    "Occupancy %" DESC;


-- Query 5: Current hospitalizations with length of stay
SELECT 
    p.last_name || ' ' || p.first_name || ' ' || COALESCE(p.middle_name, '') AS "Patient",
    d.department_name AS "Department",
    w.ward_number AS "Ward",
    b.bed_number AS "Bed",
    h.admission_date::date AS "Admission Date",
    h.expected_discharge_date AS "Expected Discharge",
    CURRENT_DATE - h.admission_date::date AS "Days Hospitalized",
    h.diagnosis AS "Diagnosis"
FROM 
    hospitalizations h
JOIN patients p ON h.patient_id = p.patient_id
JOIN beds b ON h.bed_id = b.bed_id
JOIN wards w ON b.ward_id = w.ward_id
JOIN departments d ON w.department_id = d.department_id
WHERE 
    h.status = 'active'
ORDER BY 
    "Days Hospitalized" DESC;


-- Query 6: Patients overdue for discharge
SELECT 
    p.last_name || ' ' || p.first_name || ' ' || COALESCE(p.middle_name, '') AS "Patient",
    d.department_name AS "Department",
    w.ward_number AS "Ward",
    h.expected_discharge_date AS "Expected Discharge",
    CURRENT_DATE - h.expected_discharge_date AS "Days Overdue"
FROM 
    hospitalizations h
JOIN patients p ON h.patient_id = p.patient_id
JOIN beds b ON h.bed_id = b.bed_id
JOIN wards w ON b.ward_id = w.ward_id
JOIN departments d ON w.department_id = d.department_id
WHERE 
    h.status = 'active'
    AND h.expected_discharge_date < CURRENT_DATE
ORDER BY 
    h.expected_discharge_date;


-- Query 7: Find available bed of specific type
SELECT 
    d.department_name AS "Department",
    w.ward_number AS "Ward",
    b.bed_number AS "Bed",
    bt.type_name AS "Type",
    b.status AS "Status"
FROM 
    beds b
JOIN bed_types bt ON b.bed_type_id = bt.bed_type_id
JOIN wards w ON b.ward_id = w.ward_id
JOIN departments d ON w.department_id = d.department_id
WHERE 
    b.status = 'available'
    AND bt.type_name = 'Intensive Care'
ORDER BY 
    d.department_name, w.ward_number;


-- Query 8: Top 10 most common diagnoses
SELECT 
    dis.disease_name AS "Disease",
    dis.icd10_code AS "ICD-10 Code",
    COUNT(h.hospitalization_id) AS "Number of Cases"
FROM 
    diseases dis
JOIN hospitalizations h ON dis.disease_id = h.disease_id
GROUP BY 
    dis.disease_id, dis.disease_name, dis.icd10_code
ORDER BY 
    COUNT(h.hospitalization_id) DESC
LIMIT 10;


-- Query 9: Average length of stay by department
SELECT 
    d.department_name AS "Department",
    ROUND(AVG(EXTRACT(EPOCH FROM (COALESCE(h.discharge_date, CURRENT_TIMESTAMP) - h.admission_date)) / 86400), 1) AS "Avg Stay (days)",
    COUNT(h.hospitalization_id) AS "Total Hospitalizations"
FROM 
    departments d
JOIN wards w ON d.department_id = w.department_id
JOIN beds b ON w.ward_id = b.ward_id
JOIN hospitalizations h ON b.bed_id = h.bed_id
GROUP BY 
    d.department_name
ORDER BY 
    "Avg Stay (days)" DESC;


-- Query 10: Patient search by last name
SELECT 
    patient_id AS "ID",
    last_name || ' ' || first_name || ' ' || COALESCE(middle_name, '') AS "Full Name",
    date_of_birth AS "Date of Birth",
    phone AS "Phone",
    insurance_policy AS "Insurance Policy"
FROM 
    patients
WHERE 
    LOWER(last_name) LIKE '%ivanov%'
ORDER BY 
    last_name, first_name;


-- Query 11: Ward details with bed counts
SELECT 
    d.department_name AS "Department",
    w.ward_number AS "Ward",
    w.capacity AS "Capacity",
    COUNT(b.bed_id) AS "Beds",
    SUM(CASE WHEN b.status = 'occupied' THEN 1 ELSE 0 END) AS "Occupied",
    SUM(CASE WHEN b.status = 'available' THEN 1 ELSE 0 END) AS "Available"
FROM 
    departments d
JOIN wards w ON d.department_id = w.department_id
LEFT JOIN beds b ON w.ward_id = b.ward_id
GROUP BY 
    d.department_name, w.ward_number, w.capacity
ORDER BY 
    d.department_name, w.ward_number;


-- Query 12: Hospital-wide statistics
SELECT 
    COUNT(DISTINCT d.department_id) AS "Departments",
    COUNT(DISTINCT w.ward_id) AS "Wards",
    COUNT(b.bed_id) AS "Total Beds",
    SUM(CASE WHEN b.status = 'occupied' THEN 1 ELSE 0 END) AS "Occupied Beds",
    SUM(CASE WHEN b.status = 'available' THEN 1 ELSE 0 END) AS "Available Beds",
    ROUND(100.0 * SUM(CASE WHEN b.status = 'occupied' THEN 1 ELSE 0 END) / COUNT(b.bed_id), 1) AS "Overall Occupancy %"
FROM 
    departments d
JOIN wards w ON d.department_id = w.department_id
JOIN beds b ON w.ward_id = b.ward_id;

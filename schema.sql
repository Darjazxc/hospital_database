-- Hospital Database Schema

CREATE DATABASE hospital_db;

-- Reference Tables

CREATE TABLE department_types (
    department_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE bed_types (
    bed_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE referral_types (
    referral_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE diseases (
    disease_id SERIAL PRIMARY KEY,
    icd10_code VARCHAR(10) NOT NULL UNIQUE,
    disease_name VARCHAR(500) NOT NULL,
    category VARCHAR(200)
);

-- Hospital Structure

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(200) NOT NULL,
    department_type_id INT REFERENCES department_types(department_type_id),
    floor_number INT,
    capacity INT,
    head_doctor VARCHAR(200),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wards (
    ward_id SERIAL PRIMARY KEY,
    ward_number VARCHAR(20) NOT NULL,
    department_id INT REFERENCES departments(department_id) ON DELETE CASCADE,
    capacity INT NOT NULL DEFAULT 1,
    ward_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(ward_number, department_id)
);

CREATE TABLE beds (
    bed_id SERIAL PRIMARY KEY,
    bed_number INT NOT NULL,
    ward_id INT REFERENCES wards(ward_id) ON DELETE CASCADE,
    bed_type_id INT REFERENCES bed_types(bed_type_id),
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'maintenance', 'reserved')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(bed_number, ward_id)
);

-- Patients

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('M', 'F', 'Male', 'Female')),
    passport_series VARCHAR(10),
    passport_number VARCHAR(20),
    insurance_policy VARCHAR(50),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    emergency_contact VARCHAR(200),
    emergency_phone VARCHAR(20),
    blood_type VARCHAR(10),
    allergies TEXT,
    chronic_diseases TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_patients_fullname ON patients(last_name, first_name, middle_name);

-- Referrals

CREATE TABLE referrals (
    referral_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id) ON DELETE CASCADE,
    referral_type_id INT REFERENCES referral_types(referral_type_id),
    referral_date DATE NOT NULL DEFAULT CURRENT_DATE,
    referring_organization VARCHAR(300),
    referring_doctor VARCHAR(200),
    diagnosis TEXT NOT NULL,
    disease_id INT REFERENCES diseases(disease_id),
    urgency VARCHAR(20) DEFAULT 'planned' CHECK (urgency IN ('emergency', 'urgent', 'planned')),
    notes TEXT,
    status VARCHAR(30) DEFAULT 'new' CHECK (status IN ('new', 'processed', 'placed', 'rejected', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);

-- Hospitalizations

CREATE TABLE hospitalizations (
    hospitalization_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id) ON DELETE CASCADE,
    bed_id INT REFERENCES beds(bed_id),
    referral_id INT REFERENCES referrals(referral_id),
    admission_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expected_discharge_date DATE,
    discharge_date TIMESTAMP,
    diagnosis TEXT NOT NULL,
    disease_id INT REFERENCES diseases(disease_id),
    attending_doctor VARCHAR(200),
    treatment_plan TEXT,
    discharge_diagnosis TEXT,
    discharge_summary TEXT,
    status VARCHAR(30) DEFAULT 'active' CHECK (status IN ('active', 'discharged', 'transferred', 'deceased')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Waiting Queue

CREATE TABLE placement_queue (
    queue_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id) ON DELETE CASCADE,
    referral_id INT REFERENCES referrals(referral_id),
    department_id INT REFERENCES departments(department_id),
    requested_bed_type_id INT REFERENCES bed_types(bed_type_id),
    queue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    priority INT DEFAULT 3 CHECK (priority BETWEEN 1 AND 5),
    status VARCHAR(30) DEFAULT 'queued' CHECK (status IN ('queued', 'placed', 'cancelled')),
    notes TEXT
);

-- Audit Log

CREATE TABLE bed_status_history (
    history_id SERIAL PRIMARY KEY,
    bed_id INT REFERENCES beds(bed_id) ON DELETE CASCADE,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);

-- Indexes

CREATE INDEX idx_beds_status ON beds(status);
CREATE INDEX idx_beds_ward ON beds(ward_id);
CREATE INDEX idx_wards_department ON wards(department_id);
CREATE INDEX idx_hospitalizations_patient ON hospitalizations(patient_id);
CREATE INDEX idx_hospitalizations_bed ON hospitalizations(bed_id);
CREATE INDEX idx_hospitalizations_status ON hospitalizations(status);
CREATE INDEX idx_hospitalizations_dates ON hospitalizations(admission_date, discharge_date);
CREATE INDEX idx_referrals_patient ON referrals(patient_id);
CREATE INDEX idx_referrals_status ON referrals(status);
CREATE INDEX idx_queue_status ON placement_queue(status);

-- Views

CREATE OR REPLACE VIEW available_beds AS
SELECT 
    d.department_name,
    w.ward_number,
    b.bed_number,
    bt.type_name AS bed_type,
    b.status
FROM beds b
JOIN wards w ON b.ward_id = w.ward_id
JOIN departments d ON w.department_id = d.department_id
JOIN bed_types bt ON b.bed_type_id = bt.bed_type_id
WHERE b.status = 'available';

CREATE OR REPLACE VIEW current_hospitalizations AS
SELECT 
    h.hospitalization_id,
    p.last_name || ' ' || p.first_name || ' ' || COALESCE(p.middle_name, '') AS patient_full_name,
    d.department_name,
    w.ward_number,
    b.bed_number,
    h.admission_date,
    h.diagnosis,
    h.attending_doctor,
    CURRENT_DATE - h.admission_date::date AS days_hospitalized
FROM hospitalizations h
JOIN patients p ON h.patient_id = p.patient_id
JOIN beds b ON h.bed_id = b.bed_id
JOIN wards w ON b.ward_id = w.ward_id
JOIN departments d ON w.department_id = d.department_id
WHERE h.status = 'active';

CREATE OR REPLACE VIEW department_statistics AS
SELECT 
    d.department_name,
    COUNT(b.bed_id) AS total_beds,
    SUM(CASE WHEN b.status = 'occupied' THEN 1 ELSE 0 END) AS occupied_beds,
    SUM(CASE WHEN b.status = 'available' THEN 1 ELSE 0 END) AS available_beds,
    ROUND(100.0 * SUM(CASE WHEN b.status = 'occupied' THEN 1 ELSE 0 END) / NULLIF(COUNT(b.bed_id), 0), 1) AS occupancy_percentage
FROM departments d
LEFT JOIN wards w ON d.department_id = w.department_id
LEFT JOIN beds b ON w.ward_id = b.ward_id
GROUP BY d.department_id, d.department_name;

-- Sample Data

-- Department Types
INSERT INTO department_types (type_name, description) VALUES
('Therapeutic', 'Therapeutic department'),
('Surgical', 'Surgical department'),
('Neurological', 'Neurological department'),
('Cardiology', 'Cardiology department'),
('Pediatric', 'Pediatric department');

-- Bed Types
INSERT INTO bed_types (type_name, description) VALUES
('Standard Bed', 'Standard bed'),
('Post-operative', 'Post-operative observation bed'),
('Intensive Care', 'Intensive care unit bed'),
('Pediatric Bed', 'Pediatric bed'),
('VIP Bed', 'Comfortable single room');

-- Referral Types
INSERT INTO referral_types (type_name, description) VALUES
('Emergency Ambulance', 'Referral from emergency ambulance'),
('Clinic Referral', 'Planned referral from clinic doctor'),
('Emergency Admission', 'Emergency admission without referral'),
('Planned Admission', 'Planned admission by appointment'),
('Regional Health Department', 'Referral from regional health department');

-- Diseases (ICD-10)
INSERT INTO diseases (icd10_code, disease_name, category) VALUES
('I21', 'Acute myocardial infarction', 'Circulatory system diseases'),
('I63', 'Ischemic stroke', 'Circulatory system diseases'),
('J18', 'Pneumonia', 'Respiratory system diseases'),
('K35', 'Acute appendicitis', 'Digestive system diseases'),
('K29', 'Acute gastritis', 'Digestive system diseases'),
('M54', 'Dorsalgia', 'Musculoskeletal system diseases');

-- Departments
INSERT INTO departments (department_name, department_type_id, floor_number, capacity, head_doctor, phone) VALUES
('Therapeutic Department', 1, 1, 30, 'Ivanov I.I.', '+7-495-123-45-01'),
('Surgical Department', 2, 2, 25, 'Petrov P.P.', '+7-495-123-45-02'),
('Neurological Department', 3, 3, 20, 'Sidorov S.S.', '+7-495-123-45-03'),
('Cardiology Department', 4, 4, 15, 'Kozlov K.K.', '+7-495-123-45-04');

-- Wards - Therapeutic Department
INSERT INTO wards (ward_number, department_id, capacity, ward_type) VALUES
('101', 1, 3, 'multi-bed'),
('102', 1, 2, 'double'),
('103', 1, 2, 'double'),
('104', 1, 3, 'multi-bed');

-- Wards - Surgical Department
INSERT INTO wards (ward_number, department_id, capacity, ward_type) VALUES
('201', 2, 3, 'multi-bed'),
('202', 2, 2, 'double'),
('203', 2, 3, 'multi-bed'),
('204', 2, 2, 'double');

-- Wards - Neurological Department
INSERT INTO wards (ward_number, department_id, capacity, ward_type) VALUES
('301', 3, 2, 'double'),
('302', 3, 2, 'double'),
('303', 3, 1, 'single');

-- Beds - Therapeutic Department, Ward 101
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 1, 1, 'available'),
(2, 1, 1, 'occupied'),
(3, 1, 1, 'available');

-- Beds - Therapeutic Department, Ward 102
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 2, 1, 'occupied'),
(2, 2, 1, 'available');

-- Beds - Therapeutic Department, Ward 103
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 3, 1, 'occupied'),
(2, 3, 1, 'available');

-- Beds - Therapeutic Department, Ward 104
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 4, 1, 'available'),
(2, 4, 1, 'occupied'),
(3, 4, 1, 'available');

-- Beds - Surgical Department, Ward 201
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 5, 2, 'occupied'),
(2, 5, 2, 'available'),
(3, 5, 1, 'available');

-- Beds - Surgical Department, Ward 202
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 6, 3, 'occupied'),
(2, 6, 3, 'available');

-- Beds - Surgical Department, Ward 203
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 7, 2, 'available'),
(2, 7, 2, 'occupied'),
(3, 7, 1, 'available');

-- Beds - Surgical Department, Ward 204
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 8, 3, 'occupied'),
(2, 8, 3, 'available');

-- Beds - Neurological Department
INSERT INTO beds (bed_number, ward_id, bed_type_id, status) VALUES
(1, 9, 1, 'occupied'),
(2, 9, 1, 'available'),
(1, 10, 1, 'occupied'),
(2, 10, 1, 'occupied'),
(1, 11, 5, 'available');

-- Patients
INSERT INTO patients (last_name, first_name, middle_name, date_of_birth, gender, insurance_policy, phone, address, blood_type) VALUES
('Ivanov', 'Petr', 'Sergeevich', '1985-03-15', 'M', '1234567890123456', '+7-916-123-45-67', 'Moscow, Lenina St., 10', 'A+'),
('Smirnova', 'Anna', 'Igorevna', '1990-07-22', 'F', '2345678901234567', '+7-916-234-56-78', 'Moscow, Pushkina St., 5', 'O+'),
('Popov', 'Vladimir', 'Ivanovich', '1975-11-08', 'M', '3456789012345678', '+7-916-345-67-89', 'Moscow, Chekhova St., 12', 'B+'),
('Lebedev', 'Nikolai', 'Alekseevich', '1982-05-30', 'M', '4567890123456789', '+7-916-456-78-90', 'Moscow, Gogolya St., 7', 'AB+'),
('Koroleva', 'Marina', 'Sergeevna', '1995-09-12', 'F', '5678901234567890', '+7-916-567-89-01', 'Moscow, Tverskaya St., 3', 'A-'),
('Mikhailov', 'Alexander', 'Sergeevich', '1978-02-18', 'M', '6789012345678901', '+7-916-678-90-12', 'Moscow, Arbat St., 25', 'O-');

-- Referrals
INSERT INTO referrals (patient_id, referral_type_id, referral_date, referring_organization, referring_doctor, diagnosis, disease_id, urgency, status) VALUES
(1, 2, '2025-01-10', 'Clinic #5', 'Dr. Sergeeva M.A.', 'Acute gastritis', 5, 'planned', 'placed'),
(2, 1, '2025-01-12', 'Emergency Ambulance Station #3', 'Dr. Petrov P.P.', 'Acute appendicitis', 4, 'emergency', 'placed'),
(3, 1, '2025-01-15', 'Emergency Ambulance Station #1', 'Dr. Ivanov I.I.', 'Acute myocardial infarction', 1, 'emergency', 'placed'),
(4, 3, '2025-01-17', 'Self-referral', NULL, 'Pneumonia', 3, 'urgent', 'placed'),
(5, 2, '2025-01-18', 'Clinic #2', 'Dr. Kozlova K.K.', 'Acute gastritis', 5, 'planned', 'placed'),
(6, 2, '2025-01-16', 'Clinic #7', 'Dr. Smirnov S.S.', 'Ischemic stroke', 2, 'urgent', 'placed');

-- Hospitalizations
INSERT INTO hospitalizations (patient_id, bed_id, referral_id, admission_date, expected_discharge_date, diagnosis, disease_id, attending_doctor, status) VALUES
(1, 7, 1, '2025-01-10 14:30:00', '2025-01-15', 'Acute gastritis', 5, 'Ivanov I.I.', 'active'),
(2, 14, 2, '2025-01-13 03:15:00', '2025-01-15', 'Acute appendicitis', 4, 'Petrov P.P.', 'active'),
(3, 24, 3, '2025-01-20 08:45:00', '2025-01-15', 'Acute myocardial infarction', 1, 'Sidorov S.S.', 'active'),
(4, 15, 4, '2025-01-18 16:20:00', '2025-01-15', 'Pneumonia', 3, 'Petrov P.P.', 'active'),
(5, 21, 5, '2025-01-21 11:00:00', '2025-01-15', 'Acute gastritis', 5, 'Petrov P.P.', 'active'),
(6, 2, 6, '2025-01-16 09:30:00', '2025-01-15', 'Ischemic stroke', 2, 'Ivanov I.I.', 'active');

-- Bed Status History
INSERT INTO bed_status_history (bed_id, old_status, new_status, changed_by, reason) VALUES
(2, 'available', 'occupied', 'Registrar Petrova', 'Patient placement'),
(7, 'available', 'occupied', 'Registrar Ivanova', 'Patient placement'),
(14, 'available', 'occupied', 'Registrar Sidorova', 'Emergency admission');

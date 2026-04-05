-- Security Management System Complete Database Schema
-- PostgreSQL Compatible Version with Existing Data

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    employee_id VARCHAR(50)
);

-- Insert existing users
INSERT INTO users (id, username, email, password, role, employee_id) VALUES 
(1, 'Pg123', 'paulglawu6@gmail.com', 'a31fe9656fc8d3a459e623dc8204e6d0268f8df56d734dac3ca3262edb5db883', 'admin', NULL),
(12, 'PK', 'paulglawu6@gmail.com', 'eb3102a6cb586765d01fad324523ec0bc67b9efd6a2d9589c135adfedf7922cc', 'security_officer', NULL),
(13, 'ok', 'modametey@ecobank.com', '2689367b205c16ce32ed4200942b8b8b1e262dfc70d9bc9fbc77c49699a4f1df', 'security_officer', NULL),
(14, 'Banard', 'modametey@ecobank.com', '3c77f261a156a5308fee53720276395ef78d2e7367e4225a3d3d93f4accd1dd3', 'security_officer', NULL),
(15, 'kumii2010', 'kumimichael2011@gmail.com', '96efbc43a462ab9d9c6a8173e5b322e17f218b56eb3a05a4bbc53221adebc7b3', 'security_officer', NULL);

-- Branches table
CREATE TABLE IF NOT EXISTS branches (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Insert existing branches
INSERT INTO branches (id, name) VALUES 
(28, 'Accra'),
(29, 'Kumasi'),
(30, 'Tamale'),
(31, 'Takoradi'),
(32, 'Cape Coast'),
(33, 'Ho'),
(34, 'Sunyani'),
(35, 'Bolgatanga'),
(36, 'Wa'),
(37, 'Techiman'),
(38, 'Obuasi'),
(39, 'Tema'),
(40, 'Koforidua');

-- Staff Registration table
CREATE TABLE IF NOT EXISTS staff_registration (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    department VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) NOT NULL UNIQUE,
    qr_code VARCHAR(255),
    office_location VARCHAR(200),
    address TEXT,
    selfie_path VARCHAR(255),
    fingerprint_data TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert existing staff
INSERT INTO staff_registration (id, first_name, last_name, email, phone, department, position, employee_id, office_location, address, selfie_path, created_at) VALUES
(1, 'Paul', 'Glawu', 'paulglawu6@gmail.com', '0594084145', 'Computer Science', 'Professor', 'EM01', 'n', 'Amen basic school', 'staff_photos/staff_EM01_1774200866690.png', '2026-03-22 17:34:26');

-- Security Personnel table
CREATE TABLE IF NOT EXISTS security_personnel (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch_id INTEGER REFERENCES branches(id),
    shift_time VARCHAR(50),
    user_id INTEGER REFERENCES users(id) UNIQUE
);

-- Insert existing security personnel
INSERT INTO security_personnel (id, name, branch_id, shift_time, user_id) VALUES
(8, 'ok', 28, 'Morning', 13),
(9, 'Banard', 34, 'flexible', 14),
(10, 'kumii2010', 29, 'flexible', 15);

-- Checklist Items table
CREATE TABLE IF NOT EXISTS checklist_items (
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL
);

-- Insert existing checklist items
INSERT INTO checklist_items (id, item_name) VALUES
(1, 'Gate Locked'),
(2, 'Lights Working'),
(3, 'CCTV Active'),
(4, 'Fire Extinguisher OK'),
(5, 'Perimeter Security Check'),
(6, 'Building Access Control'),
(7, 'Emergency Equipment Check'),
(8, 'Surveillance System Check'),
(9, 'Lighting System Check');

-- Items table (if needed)
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES branches(id),
    item_name VARCHAR(100) NOT NULL
);

-- Shifts table
CREATE TABLE IF NOT EXISTS shifts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    start_time TIMESTAMP,
    end_time TIMESTAMP
);

-- Insert existing shifts
INSERT INTO shifts (id, user_id, start_time, end_time) VALUES
(2, 14, '2026-03-20 08:40:38', '2026-03-20 08:40:48'),
(4, 14, '2026-03-20 09:12:59', '2026-03-20 09:13:08'),
(5, 14, '2026-03-20 15:46:04', '2026-03-23 08:54:04'),
(9, 14, '2026-03-21 18:03:25', '2026-03-23 08:53:43'),
(10, 14, '2026-03-21 18:31:44', '2026-03-22 20:24:32'),
(21, 14, '2026-03-23 09:05:05', '2026-03-23 09:05:15'),
(22, 14, '2026-03-23 09:43:42', '2026-03-23 09:44:06'),
(23, 15, '2026-03-23 09:50:13', '2026-03-23 09:50:24'),
(24, 15, '2026-03-23 09:52:54', '2026-03-23 09:53:04'),
(25, 15, '2026-03-23 10:00:02', '2026-03-23 10:00:12'),
(26, 15, '2026-03-23 10:05:37', '2026-03-23 10:05:50'),
(27, 15, '2026-03-23 10:07:42', '2026-03-23 10:07:52'),
(28, 15, '2026-03-23 10:12:18', '2026-03-23 10:13:04'),
(29, 15, '2026-03-23 10:14:11', '2026-03-23 10:14:20'),
(30, 15, '2026-03-23 10:14:33', '2026-03-23 10:14:42'),
(31, 15, '2026-03-23 10:16:50', '2026-03-23 10:16:59'),
(32, 15, '2026-03-23 10:18:11', '2026-03-23 10:18:22'),
(33, 15, '2026-03-23 10:20:56', '2026-03-23 10:21:07'),
(34, 15, '2026-03-23 10:22:47', '2026-03-23 10:23:33'),
(35, 15, '2026-03-23 10:23:54', '2026-03-23 10:23:54'),
(36, 15, '2026-03-23 10:24:32', '2026-03-23 10:24:32'),
(37, 15, '2026-03-23 10:27:33', '2026-03-23 10:27:43'),
(38, 15, '2026-03-23 10:30:39', '2026-03-23 10:32:47'),
(39, 15, '2026-03-23 10:32:47', '2026-03-23 10:32:47'),
(40, 15, '2026-03-23 10:34:37', '2026-03-23 10:34:37'),
(41, 15, '2026-03-23 10:35:39', '2026-03-23 10:35:39'),
(42, 15, '2026-03-23 10:36:47', '2026-03-23 10:36:47'),
(43, 15, '2026-03-23 10:37:59', '2026-03-23 10:37:59'),
(44, 15, '2026-03-23 10:39:08', '2026-03-23 10:39:08'),
(45, 15, '2026-03-23 10:39:16', '2026-03-23 10:39:16'),
(46, 15, '2026-03-23 10:39:30', '2026-03-23 10:39:30'),
(47, 15, '2026-03-23 10:39:38', '2026-03-23 10:39:38'),
(48, 15, '2026-03-23 10:40:40', '2026-03-23 10:40:40'),
(49, 15, '2026-03-23 10:41:23', '2026-03-23 10:41:23'),
(50, 13, '2026-03-23 10:48:39', '2026-03-23 10:51:10');

-- Attendance table
CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    staff_id INTEGER REFERENCES staff_registration(id),
    employee_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    selfie_path VARCHAR(255),
    face_verified BOOLEAN DEFAULT FALSE,
    attendance_type VARCHAR(20) DEFAULT 'qr'
);

-- Insert existing attendance
INSERT INTO attendance (id, user_id, staff_id, employee_id, first_name, last_name, latitude, longitude, check_in_time, selfie_path, face_verified, attendance_type) VALUES
(1, NULL, 1, 'EM01', 'Paul', 'Glawu', 6.687590, -1.608170, '2026-03-22 18:30:02', '', 1, 'qr'),
(2, NULL, 1, 'EM01', 'Paul', 'Glawu', 6.687574, -1.608193, '2026-03-23 08:54:38', '', 1, 'qr');

-- Shift Checks table
CREATE TABLE IF NOT EXISTS shift_checks (
    id SERIAL PRIMARY KEY,
    shift_id INTEGER REFERENCES shifts(id),
    personnel_id INTEGER REFERENCES security_personnel(id),
    item_id INTEGER REFERENCES checklist_items(id),
    status VARCHAR(20) NOT NULL,
    reason TEXT,
    check_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert existing shift checks
INSERT INTO shift_checks (id, shift_id, personnel_id, item_id, status, reason, check_time) VALUES
(1, 3, 9, 3, 'Not ok', 'Missing ', '2026-03-20 16:21:19'),
(11, 49, 10, 1, 'NOT_OK', 'missing', '2026-03-23 10:51:10'),
(12, 49, 10, 2, 'OK', '', '2026-03-23 10:51:10'),
(13, 49, 10, 3, 'OK', '', '2026-03-23 10:51:10'),
(14, 49, 10, 4, 'OK', '', '2026-03-23 10:51:10'),
(15, 49, 10, 5, 'OK', '', '2026-03-23 10:51:10'),
(16, 49, 10, 6, 'OK', '', '2026-03-23 10:51:10'),
(17, 49, 10, 7, 'OK', '', '2026-03-23 10:51:10'),
(18, 49, 10, 8, 'OK', '', '2026-03-23 10:51:10'),
(19, 49, 10, 9, 'OK', '', '2026-03-23 10:51:10'),
(20, 50, 8, 1, 'OK', '', '2026-03-23 10:53:40'),
(21, 50, 8, 2, 'NOT_OK', 'pokk', '2026-03-23 10:53:40'),
(22, 50, 8, 3, 'OK', '', '2026-03-23 10:53:40'),
(23, 50, 8, 4, 'OK', '', '2026-03-23 10:53:40'),
(24, 50, 8, 5, 'OK', '', '2026-03-23 10:53:40'),
(25, 50, 8, 6, 'OK', '', '2026-03-23 10:53:40'),
(26, 50, 8, 7, 'OK', '', '2026-03-23 10:53:40'),
(27, 50, 8, 8, 'OK', '', '2026-03-23 10:53:40'),
(28, 50, 8, 9, 'OK', '', '2026-03-23 10:53:40');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_staff_registration_email ON staff_registration(email);
CREATE INDEX IF NOT EXISTS idx_staff_registration_employee_id ON staff_registration(employee_id);
CREATE INDEX IF NOT EXISTS idx_attendance_user_id ON attendance(user_id);
CREATE INDEX IF NOT EXISTS idx_attendance_check_in_time ON attendance(check_in_time);
CREATE INDEX IF NOT EXISTS idx_shift_checks_personnel ON shift_checks(personnel_id);
CREATE INDEX IF NOT EXISTS idx_shift_checks_date ON shift_checks(check_time);

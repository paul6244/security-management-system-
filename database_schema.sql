-- Security Management System Database Schema
-- PostgreSQL Compatible Version

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Branches table
CREATE TABLE IF NOT EXISTS branches (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Security Personnel table
CREATE TABLE IF NOT EXISTS security_personnel (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch_id INTEGER REFERENCES branches(id),
    shift_time VARCHAR(50) NOT NULL,
    user_id INTEGER REFERENCES users(id) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staff Registration table (enhanced)
CREATE TABLE IF NOT EXISTS staff_registration (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    department VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) NOT NULL UNIQUE,
    office_location VARCHAR(200),
    address TEXT,
    selfie_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Checklist Items table
CREATE TABLE IF NOT EXISTS checklist_items (
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shifts table
CREATE TABLE IF NOT EXISTS shifts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attendance table
CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    staff_id INTEGER REFERENCES staff_registration(id),
    employee_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    selfie_path VARCHAR(255),
    face_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shift Checks table
CREATE TABLE IF NOT EXISTS shift_checks (
    id SERIAL PRIMARY KEY,
    personnel_id INTEGER REFERENCES security_personnel(id),
    item_id INTEGER REFERENCES checklist_items(id),
    status VARCHAR(20) NOT NULL, -- 'OK', 'NOT_OK'
    reason TEXT,
    check_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    check_date DATE DEFAULT CURRENT_DATE
);

-- Insert default data
INSERT INTO branches (name, location) VALUES 
('Main Office', 'Building A, Floor 1'),
('Branch Office 1', 'Building B, Floor 2'),
('Branch Office 2', 'Building C, Floor 1')
ON CONFLICT DO NOTHING;

INSERT INTO checklist_items (item_name, description, category) VALUES 
('Main Entrance', 'Check main entrance security', 'Security'),
('Emergency Exit', 'Verify emergency exit accessibility', 'Safety'),
('CCTV Cameras', 'Check CCTV camera functionality', 'Security'),
('Fire Extinguisher', 'Inspect fire extinguisher status', 'Safety'),
('First Aid Kit', 'Check first aid kit availability', 'Safety'),
('Parking Area', 'Monitor parking area security', 'Security'),
('Server Room', 'Verify server room access', 'IT Security'),
('Document Storage', 'Check document storage security', 'Security')
ON CONFLICT DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_staff_registration_email ON staff_registration(email);
CREATE INDEX IF NOT EXISTS idx_staff_registration_employee_id ON staff_registration(employee_id);
CREATE INDEX IF NOT EXISTS idx_attendance_user_id ON attendance(user_id);
CREATE INDEX IF NOT EXISTS idx_attendance_check_in_time ON attendance(check_in_time);
CREATE INDEX IF NOT EXISTS idx_shift_checks_personnel ON shift_checks(personnel_id);
CREATE INDEX IF NOT EXISTS idx_shift_checks_date ON shift_checks(check_date);

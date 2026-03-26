-- Clean Database Setup for Security Management System
-- Handles existing data and conflicts

-- First, let's check what's already in the database
SELECT 'Checking existing tables...' as status;

-- Create tables (they will be skipped if they exist)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    employee_id VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS branches (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

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

CREATE TABLE IF NOT EXISTS security_personnel (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch_id INTEGER REFERENCES branches(id),
    shift_time VARCHAR(50),
    user_id INTEGER REFERENCES users(id) UNIQUE
);

CREATE TABLE IF NOT EXISTS checklist_items (
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS shifts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    start_time TIMESTAMP,
    end_time TIMESTAMP
);

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

CREATE TABLE IF NOT EXISTS shift_checks (
    id SERIAL PRIMARY KEY,
    shift_id INTEGER REFERENCES shifts(id),
    personnel_id INTEGER REFERENCES security_personnel(id),
    item_id INTEGER REFERENCES checklist_items(id),
    status VARCHAR(20) NOT NULL,
    reason TEXT,
    check_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert data with conflict handling
INSERT INTO branches (name) VALUES 
('Accra'), ('Kumasi'), ('Tamale'), ('Takoradi'), ('Cape Coast'),
('Ho'), ('Sunyani'), ('Bolgatanga'), ('Wa'), ('Techiman'),
('Obuasi'), ('Tema'), ('Koforidua')
ON CONFLICT (name) DO NOTHING;

INSERT INTO checklist_items (item_name) VALUES 
('Gate Locked'), ('Lights Working'), ('CCTV Active'), ('Fire Extinguisher OK'),
('Perimeter Security Check'), ('Building Access Control'), ('Emergency Equipment Check'),
('Surveillance System Check'), ('Lighting System Check')
ON CONFLICT DO NOTHING;

-- Insert users (handle conflicts)
INSERT INTO users (username, email, password, role, employee_id) VALUES 
('Pg123', 'paulglawu6@gmail.com', 'a31fe9656fc8d3a459e623dc8204e6d0268f8df56d734dac3ca3262edb5db883', 'admin', NULL),
('PK', 'pk@example.com', 'eb3102a6cb586765d01fad324523ec0bc67b9efd6a2d9589c135adfedf7922cc', 'security_officer', NULL),
('ok', 'ok@example.com', '2689367b205c16ce32ed4200942b8b8b1e262dfc70d9bc9fbc77c49699a4f1df', 'security_officer', NULL),
('Banard', 'banard@example.com', '3c77f261a156a5308fee53720276395ef78d2e7367e4225a3d3d93f4accd1dd3', 'security_officer', NULL),
('kumii2010', 'kumii2010@example.com', '96efbc43a462ab9d9c6a8173e5b322e17f218b56eb3a05a4bbc53221adebc7b3', 'security_officer', NULL)
ON CONFLICT (username) DO UPDATE SET 
    email = EXCLUDED.email,
    password = EXCLUDED.password,
    role = EXCLUDED.role;

-- Insert staff registration
INSERT INTO staff_registration (first_name, last_name, email, phone, department, position, employee_id, office_location, address, selfie_path) VALUES 
('Paul', 'Glawu', 'paulglawu6@gmail.com', '0594084145', 'Computer Science', 'Professor', 'EM01', 'n', 'Amen basic school', 'staff_photos/staff_EM01_1774200866690.png')
ON CONFLICT (email) DO NOTHING;

-- Get user IDs for security personnel
DO $$
DECLARE
    ok_user_id INTEGER;
    banard_user_id INTEGER;
    kumii_user_id INTEGER;
    accra_branch_id INTEGER;
    sunyani_branch_id INTEGER;
    kumasi_branch_id INTEGER;
BEGIN
    -- Get user IDs
    SELECT id INTO ok_user_id FROM users WHERE username = 'ok';
    SELECT id INTO banard_user_id FROM users WHERE username = 'Banard';
    SELECT id INTO kumii_user_id FROM users WHERE username = 'kumii2010';
    
    -- Get branch IDs
    SELECT id INTO accra_branch_id FROM branches WHERE name = 'Accra';
    SELECT id INTO sunyani_branch_id FROM branches WHERE name = 'Sunyani';
    SELECT id INTO kumasi_branch_id FROM branches WHERE name = 'Kumasi';
    
    -- Insert security personnel
    INSERT INTO security_personnel (name, branch_id, shift_time, user_id) VALUES 
    ('ok', accra_branch_id, 'Morning', ok_user_id),
    ('Banard', sunyani_branch_id, 'flexible', banard_user_id),
    ('kumii2010', kumasi_branch_id, 'flexible', kumii_user_id)
    ON CONFLICT (user_id) DO NOTHING;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_staff_registration_email ON staff_registration(email);
CREATE INDEX IF NOT EXISTS idx_staff_registration_employee_id ON staff_registration(employee_id);
CREATE INDEX IF NOT EXISTS idx_attendance_user_id ON attendance(user_id);
CREATE INDEX IF NOT EXISTS idx_attendance_check_in_time ON attendance(check_in_time);
CREATE INDEX IF NOT EXISTS idx_shift_checks_personnel ON shift_checks(personnel_id);
CREATE INDEX IF NOT EXISTS idx_shift_checks_date ON shift_checks(check_time);

-- Show final status
SELECT 'Database setup completed successfully!' as status;
SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as branch_count FROM branches;
SELECT COUNT(*) as checklist_count FROM checklist_items;
SELECT COUNT(*) as personnel_count FROM security_personnel;

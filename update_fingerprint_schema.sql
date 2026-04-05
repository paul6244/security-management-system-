-- Database Update Script for Fingerprint Support
-- This script adds fingerprint_data column to existing staff_registration table

-- Add fingerprint_data column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'staff_registration' 
        AND column_name = 'fingerprint_data'
    ) THEN
        ALTER TABLE staff_registration ADD COLUMN fingerprint_data TEXT;
        RAISE NOTICE 'Added fingerprint_data column to staff_registration table';
    ELSE
        RAISE NOTICE 'fingerprint_data column already exists in staff_registration table';
    END IF;
END $$;

-- Update existing staff records to have NULL fingerprint_data (if needed)
UPDATE staff_registration 
SET fingerprint_data = NULL 
WHERE fingerprint_data IS NOT NULL AND fingerprint_data = '';

-- Test the schema
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'staff_registration' 
AND column_name = 'fingerprint_data';

-- Show sample data
SELECT employee_id, first_name, last_name, 
       CASE 
           WHEN fingerprint_data IS NULL THEN 'Not Registered'
           WHEN fingerprint_data = '' THEN 'Empty'
           ELSE 'Registered'
       END as fingerprint_status
FROM staff_registration 
ORDER BY employee_id;

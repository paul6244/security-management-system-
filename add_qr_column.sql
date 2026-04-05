-- Add missing qr_code column to staff_registration table
ALTER TABLE staff_registration ADD COLUMN qr_code VARCHAR(255);

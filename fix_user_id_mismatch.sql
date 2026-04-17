-- Fix User ID Mismatch in Security Personnel Table
-- This script fixes the mismatched user_id references

-- First, let's see the current state
SELECT 
    sp.id as personnel_id, 
    sp.name as personnel_name, 
    sp.user_id as current_user_id,
    u.id as users_table_id,
    u.username as username,
    CASE 
        WHEN u.id IS NOT NULL THEN 'MATCH'
        ELSE 'MISMATCH'
    END as status
FROM security_personnel sp
LEFT JOIN users u ON sp.user_id = u.id
ORDER BY sp.id;

-- Fix the mismatches based on the data we have
-- Personnel ID 8 (ok) should have user_id 13
UPDATE security_personnel 
SET user_id = 13 
WHERE id = 8 AND user_id != 13;

-- Personnel ID 9 (Banard) should have user_id 14  
UPDATE security_personnel 
SET user_id = 14 
WHERE id = 9 AND user_id != 14;

-- Personnel ID 10 (kumii2010) should have user_id 15
UPDATE security_personnel 
SET user_id = 15 
WHERE id = 10 AND user_id != 15;

-- Verify the fixes
SELECT 
    sp.id as personnel_id, 
    sp.name as personnel_name, 
    sp.user_id as current_user_id,
    u.id as users_table_id,
    u.username as username,
    CASE 
        WHEN u.id IS NOT NULL THEN 'MATCH'
        ELSE 'MISMATCH'
    END as status
FROM security_personnel sp
LEFT JOIN users u ON sp.user_id = u.id
ORDER BY sp.id;

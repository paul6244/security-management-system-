-- Create branch_checklist_items table for branch-specific checklist management
-- This table allows different branches to have different checklist items

CREATE TABLE IF NOT EXISTS branch_checklist_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    item_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES checklist_items(id) ON DELETE CASCADE,
    UNIQUE KEY unique_branch_item (branch_id, item_id)
);

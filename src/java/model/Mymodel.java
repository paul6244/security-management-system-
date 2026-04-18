package model;

import java.sql.*;
import utility.universalManager;
import config.DatabaseConfig;

public class Mymodel {

    static Connection con;

    // ---------------- Database Connection ----------------
    public static void connection() {
        try {
            con = DatabaseConfig.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ---------------- Check if username exists ----------------
    public static boolean userExists(String username) {
        boolean exists = false;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM users WHERE username = ?")) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                exists = rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return exists;
    }

    // ---------------- Save user and assign role ----------------
    public static boolean saveUserWithRole(String username, String email, String password,
                                           String role, String branch_id, String shift_time) {
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement ps2 = null;
        ResultSet rs = null;
        
        try {
            System.out.println("DEBUG → Starting saveUserWithRole");
            System.out.println("DEBUG → Role: " + role);
            System.out.println("DEBUG → Branch ID: " + branch_id);
            System.out.println("DEBUG → Shift Time: " + shift_time);
            
            // Hash password
            String hashed = universalManager.hashPassword(password);
            System.out.println("DEBUG → Password hashed successfully");

            // Get database connection
            conn = DatabaseConfig.getConnection();
            if (conn == null) {
                System.out.println("ERROR: Database connection is null");
                return false;
            }
            System.out.println("DEBUG → Database connection established");

            // Start transaction
            conn.setAutoCommit(false);
            System.out.println("DEBUG → Transaction started");

            // Save user
            String sql = "INSERT INTO users(username,email,password,role) VALUES(?,?,?,?)";
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, hashed);
            ps.setString(4, role);
            
            int userRows = ps.executeUpdate();
            System.out.println("DEBUG → User insert executed, rows affected: " + userRows);

            rs = ps.getGeneratedKeys();
            int userId = 0;
            if (rs.next()) {
                userId = rs.getInt(1);
                System.out.println("DEBUG → Generated user ID: " + userId);
            }
            
            // If security officer, save extra details
            if ("security_officer".equals(role)) {
                if (branch_id == null || branch_id.trim().isEmpty()) {
                    System.out.println("ERROR: Branch ID is null or empty");
                    throw new Exception("Branch is required");
                }

                if (shift_time == null || shift_time.trim().isEmpty()) {
                    System.out.println("ERROR: Shift time is null or empty");
                    throw new Exception("Shift time is required");
                }

                System.out.println("DEBUG: Inserting into security_personnel with name=" + username + ", branch_id=" + branch_id + ", shift_time=" + shift_time + ", user_id=" + userId);
                
                String secSql = "INSERT INTO security_personnel(name,branch_id,shift_time,user_id) VALUES(?,?,?,?)";
                ps2 = conn.prepareStatement(secSql);

                ps2.setString(1, username);  // Use username as name
                ps2.setInt(2, Integer.parseInt(branch_id.trim()));
                ps2.setString(3, shift_time.trim());
                ps2.setInt(4, userId);

                int secRows = ps2.executeUpdate();
                System.out.println("DEBUG → Security personnel insert executed, rows affected: " + secRows);
            }
           
            // Commit transaction
            conn.commit();
            System.out.println("DEBUG → Transaction committed successfully");
            return true;

        } catch (Exception e) {
            System.out.println("ERROR in saveUserWithRole: " + e.getMessage());
            e.printStackTrace();
            
            // Rollback transaction if error
            try {
                if (conn != null) {
                    conn.rollback();
                    System.out.println("DEBUG → Transaction rolled back");
                }
            } catch (Exception rollbackEx) {
                System.out.println("ERROR during rollback: " + rollbackEx.getMessage());
            }
            
            return false;
        } finally {
            // Clean up resources
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (ps2 != null) ps2.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                    System.out.println("DEBUG → Connection closed");
                }
            } catch (Exception cleanupEx) {
                System.out.println("ERROR during cleanup: " + cleanupEx.getMessage());
            }
        }
    }

    // ---------------- Get Branches ----------------
    public static ResultSet getBranches() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT id, name FROM branches";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Login ----------------
    public static String getUserRole(String username, String password) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConfig.getConnection();
            if (conn == null) {
                System.out.println("ERROR: Database connection is null in getUserRole");
                return null;
            }
            
            String hash = universalManager.hashPassword(password);
            System.out.println("DEBUG: Attempting login for user: " + username);

            String sql = "SELECT role FROM users WHERE username=? AND password=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, hash);

            rs = ps.executeQuery();
            if (rs.next()) {
                String role = rs.getString("role");
                System.out.println("DEBUG: Login successful for user: " + username + ", role: " + role);
                return role;
            } else {
                System.out.println("DEBUG: Login failed for user: " + username + " - no matching record");
                return null;
            }
            
        } catch (Exception e) {
            System.out.println("ERROR in getUserRole: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                System.out.println("ERROR closing resources in getUserRole: " + e.getMessage());
            }
        }
    }

    // ---------------- Update User Password ----------------
    public static boolean updateUserPassword(String username, String newPassword) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            String hashed = universalManager.hashPassword(newPassword);
            String sql = "UPDATE users SET password = ? WHERE username = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, hashed);
            ps.setString(2, username);

            int result = ps.executeUpdate();
            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ---------------- Dashboard Statistics Methods ----------------
    public static int getTotalPersonnel() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT COUNT(*) FROM security_personnel sp " +
                         "INNER JOIN users u ON sp.user_id = u.id " +
                         "WHERE u.username IS NOT NULL AND u.email IS NOT NULL";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                rs.close();
                ps.close();
                conn.close();
                return count;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static int getTotalBranches() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM branches");
            if (rs.next()) {
                int count = rs.getInt(1);
                rs.close();
                stmt.close();
                conn.close();
                return count;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static int getTotalReports() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM shift_checks");
            if (rs.next()) {
                int count = rs.getInt(1);
                rs.close();
                stmt.close();
                conn.close();
                return count;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static int getTotalIncidents() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM shift_checks WHERE status='NOT_OK' OR status='Not ok'");
            if (rs.next()) {
                int count = rs.getInt(1);
                rs.close();
                stmt.close();
                conn.close();
                return count;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static ResultSet getReportsByDate() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT DATE(check_time) AS date, COUNT(*) AS total FROM shift_checks GROUP BY DATE(check_time) ORDER BY DATE(check_time)";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Get Reports ----------------
    public static ResultSet getReports() {
        connection();
        try {
            String sql = "SELECT u.username, b.name AS branch, ci.item_name, " +
                         "sc.status, sc.reason, sc.check_time, sc.id " +
                         "FROM shift_checks sc " +
                         "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                         "JOIN users u ON sp.user_id = u.id " +
                         "JOIN branches b ON sp.branch_id = b.id " +
                         "JOIN checklist_items ci ON sc.item_id = ci.id " +
                         "ORDER BY sc.check_time DESC";

            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();

        } catch(Exception e){
            e.printStackTrace();
        }
        return null;
    }

    public static boolean updateUserPassword(String username, String newPassword) {
        connection();
        try {
            String hashed = universalManager.hashPassword(newPassword);
            String sql = "UPDATE users SET password = ? WHERE username = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, hashed);
            ps.setString(2, username);

            int result = ps.executeUpdate();
            con.close();
            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static ResultSet getFilteredReports(String dateFrom, String dateTo, String branchId, String status) {
        connection();
        try {
            StringBuilder sql = new StringBuilder(
                "SELECT u.username, b.name AS branch, ci.item_name, " +
                "sc.status, sc.reason, sc.check_time, sc.id " +
                "FROM shift_checks sc " +
                "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                "JOIN users u ON sp.user_id = u.id " +
                "JOIN branches b ON sp.branch_id = b.id " +
                "JOIN checklist_items ci ON sc.item_id = ci.id " +
                "WHERE 1=1"
            );

            // Add filters dynamically
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                sql.append(" AND DATE(sc.check_time) >= ?");
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                sql.append(" AND DATE(sc.check_time) <= ?");
            }
            if (branchId != null && !branchId.trim().isEmpty()) {
                sql.append(" AND b.id = ?");
            }
            if (status != null && !status.trim().isEmpty()) {
                if ("OK".equals(status)) {
                    sql.append(" AND sc.status = 'OK'");
                } else if ("NOT_OK".equals(status)) {
                    sql.append(" AND sc.status = 'NOT_OK'");
                }
            }

            sql.append(" ORDER BY sc.check_time DESC");

            PreparedStatement ps = con.prepareStatement(sql.toString());

            // Set parameters dynamically
            int paramIndex = 1;
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            if (branchId != null && !branchId.trim().isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(branchId));
            }

            return ps.executeQuery();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ResultSet getIncidentsByBranch() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            // Fixed query to use correct joins and include both 'NOT_OK' and 'Not ok' status variations
            String sql = "SELECT b.name as branch_name, COUNT(sc.id) as total " +
                        "FROM shift_checks sc " +
                        "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                        "JOIN branches b ON sp.branch_id = b.id " +
                        "WHERE (sc.status='NOT_OK' OR sc.status='Not ok') " +
                        "GROUP BY b.name " +
                        "ORDER BY b.name";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ResultSet getAllPersonnel() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT sp.id, sp.name, sp.shift_time, u.email, b.name as branch_name, u.username " +
                        "FROM security_personnel sp " +
                        "JOIN branches b ON sp.branch_id = b.id " +
                        "INNER JOIN users u ON sp.user_id = u.id " +
                        "WHERE u.username IS NOT NULL AND u.email IS NOT NULL " +
                        "ORDER BY u.username";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ResultSet getFilteredReports(String dateFrom, String dateTo, String branch, String status) {
        try {
            Connection conn = DatabaseConfig.getConnection();
            StringBuilder sql = new StringBuilder("SELECT sc.check_time, u.username, b.name as branch, ci.item_name, sc.status, sc.reason " +
                        "FROM shift_checks sc " +
                        "JOIN branches b ON sc.branch_id = b.id " +
                        "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                        "JOIN users u ON sp.user_id = u.id " +
                        "JOIN checklist_items ci ON sc.item_id = ci.id " +
                        "WHERE 1=1");
            
            if (dateFrom != null && !dateFrom.isEmpty()) {
                sql.append(" AND DATE(sc.check_time) >= ?");
            }
            if (dateTo != null && !dateTo.isEmpty()) {
                sql.append(" AND DATE(sc.check_time) <= ?");
            }
            if (branch != null && !branch.isEmpty()) {
                sql.append(" AND b.name = ?");
            }
            if (status != null && !status.isEmpty()) {
                if (status.equals("all")) {
                    // Get all records including incidents
                } else {
                    sql.append(" AND sc.status = ?");
                }
            }
            
            sql.append(" ORDER BY sc.check_time DESC");
            
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            
            if (dateFrom != null && !dateFrom.isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            if (branch != null && !branch.isEmpty()) {
                ps.setString(paramIndex++, branch);
            }
            if (status != null && !status.isEmpty() && !status.equals("all")) {
                ps.setString(paramIndex++, status);
            }
            
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ResultSet getChecklistItems() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT id, item_name FROM checklist_items ORDER BY item_name";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get all users (including security personnel)
    public static ResultSet getAllUsers() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT u.id, u.username, u.email, u.role, u.created_at, " +
                        "sp.name as personnel_name, sp.shift_time, b.name as branch_name " +
                        "FROM users u " +
                        "LEFT JOIN security_personnel sp ON u.id = sp.user_id " +
                        "LEFT JOIN branches b ON sp.branch_id = b.id " +
                        "ORDER BY u.username";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Delete/remove personnel
    public static boolean deletePersonnel(int personnelId) {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "DELETE FROM security_personnel WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, personnelId);
            int result = ps.executeUpdate();
            ps.close();
            conn.close();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get all security personnel for admin view
    public static ResultSet getAllSecurityPersonnel() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT sp.id, sp.name, sp.shift_time, sp.email, b.name as branch_name, u.username " +
                        "FROM security_personnel sp " +
                        "JOIN branches b ON sp.branch_id = b.id " +
                        "JOIN users u ON sp.user_id = u.id " +
                        "ORDER BY sp.name";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get incidents by branch for chart
    public static ResultSet getIncidentsByBranchForChart() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            // Modified query to include branches with 0 incidents and handle null branch_id
            String sql = "SELECT b.name as branch_name, COUNT(sc.id) as total " +
                        "FROM branches b " +
                        "LEFT JOIN shift_checks sc ON b.id = sc.branch_id AND sc.status = 'NOT_OK' " +
                        "GROUP BY b.name " +
                        "ORDER BY b.name";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get incident reports with personnel and user details
    public static ResultSet getIncidentReports(String dateFrom, String dateTo, String branch, String status) {
        try {
            Connection conn = DatabaseConfig.getConnection();
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT sc.id, sc.check_time, sc.status, sc.reason, ");
            sql.append("sp.name as personnel_name, u.username as user_name, b.name as branch_name, ");
            sql.append("sc.item_name ");
            sql.append("FROM shift_checks sc ");
            sql.append("JOIN security_personnel sp ON sc.personnel_id = sp.id ");
            sql.append("JOIN users u ON sp.user_id = u.id ");
            sql.append("JOIN branches b ON sp.branch_id = b.id ");
            sql.append("WHERE 1=1 ");
            
            if (dateFrom != null && !dateFrom.isEmpty()) {
                sql.append("AND DATE(sc.check_time) >= ? ");
            }
            if (dateTo != null && !dateTo.isEmpty()) {
                sql.append("AND DATE(sc.check_time) <= ? ");
            }
            if (branch != null && !branch.isEmpty()) {
                sql.append("AND b.name = ? ");
            }
            if (status != null && !status.isEmpty()) {
                sql.append("AND sc.status = ? ");
            }
            
            sql.append("ORDER BY sc.check_time DESC");
            
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            
            if (dateFrom != null && !dateFrom.isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            if (branch != null && !branch.isEmpty()) {
                ps.setString(paramIndex++, branch);
            }
            if (status != null && !status.isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get all branches for reports filtering
    public static ResultSet getAllBranches() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT id, name FROM branches ORDER BY name";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Simple method to check if personnel table has data
    public static int getPersonnelCount() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT COUNT(*) FROM security_personnel";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                rs.close();
                ps.close();
                return count;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Check if email exists
    public static boolean emailExists(String email) {
        try {
            Connection conn = DatabaseConfig.getConnection();
            String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int count = rs.getInt(1);
                rs.close();
                ps.close();
                conn.close();
                return count > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

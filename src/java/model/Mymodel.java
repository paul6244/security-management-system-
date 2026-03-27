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
        try (Connection conn = DatabaseConfig.getConnection()) {
            System.out.println("DEBUG → Role: " + role);
            System.out.println("DEBUG → Branch ID: " + branch_id);
            System.out.println("DEBUG → Shift Time: " + shift_time);
            
            String hashed = universalManager.hashPassword(password);

            // Save user
            String sql = "INSERT INTO users(username,email,password,role) VALUES(?,?,?,?)";
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, hashed);
            ps.setString(4, role);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            int userId = 0;
            if (rs.next()) userId = rs.getInt(1);

            // If security officer, save extra details
            if ("security_officer".equals(role)) {
                if (branch_id == null || branch_id.trim().isEmpty()) {
                    throw new Exception("Branch is required");
                }

                if (shift_time == null || shift_time.trim().isEmpty()) {
                    throw new Exception("Shift time is required");
                }

                String secSql = "INSERT INTO security_personnel(name,branch_id,shift_time,user_id) VALUES(?,?,?,?)";
                PreparedStatement ps2 = conn.prepareStatement(secSql);

                ps2.setString(1, username);
                ps2.setInt(2, Integer.parseInt(branch_id.trim()));
                ps2.setString(3, shift_time.trim());
                ps2.setInt(4, userId);

                int rows = ps2.executeUpdate();
                System.out.println("Inserted rows: " + rows);
            }
           
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
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
        try {
            Connection conn = DatabaseConfig.getConnection();
            String hash = universalManager.hashPassword(password);

            String sql = "SELECT role FROM users WHERE username=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, hash);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String role = rs.getString("role");
                rs.close();
                ps.close();
                conn.close();
                return role;
            }
            
            rs.close();
            ps.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
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
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM security_personnel");
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
            String sql = "SELECT DATE(check_date) AS date, COUNT(*) AS total FROM shift_checks GROUP BY DATE(check_date)";
            PreparedStatement ps = conn.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ResultSet getIncidentsByBranch() {
        try {
            Connection conn = DatabaseConfig.getConnection();
            // Modified query to include both 'NOT_OK' and 'Not ok' status variations
            // Use column names that match the reports.jsp expectations
            String sql = "SELECT b.name as branch_name, COUNT(sc.id) as total " +
                        "FROM branches b " +
                        "LEFT JOIN shift_checks sc ON b.id = sc.branch_id AND (sc.status='NOT_OK' OR sc.status='Not ok') " +
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
                        "LEFT JOIN users u ON sp.user_id = u.id";
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
}

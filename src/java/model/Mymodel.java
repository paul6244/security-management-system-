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
        connection();

        System.out.println("DEBUG → Role: " + role);
        System.out.println("DEBUG → Branch ID: " + branch_id);
        System.out.println("DEBUG → Shift Time: " + shift_time);
        try {
            String hashed = universalManager.hashPassword(password);

            // Save user
            String sql = "INSERT INTO users(username,email,password,role) VALUES(?,?,?,?)";
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
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
            PreparedStatement ps2 = con.prepareStatement(secSql);

            ps2.setString(1, username);
            ps2.setInt(2, Integer.parseInt(branch_id.trim()));
            ps2.setString(3, shift_time.trim());
            ps2.setInt(4, userId);

            int rows = ps2.executeUpdate();
            System.out.println("Inserted rows: " + rows);
    }
           
            con.close();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public static ResultSet getChecklistItems() {
    connection();
    try {
        String sql = "SELECT * FROM checklist_items";
        PreparedStatement ps = con.prepareStatement(sql);
        return ps.executeQuery();
    } catch(Exception e){
        e.printStackTrace();
    }
    return null;
}

    // ---------------- Get All Users (Staff/Teachers/Lecturers) ----------------
    public static ResultSet getAllUsers() {
        connection();
        try {
            String sql = "SELECT id, username, email, role FROM users ORDER BY username";
            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Get All Users With Personnel Details ----------------
    public static ResultSet getAllUsersWithPersonnelDetails() {
        connection();
        try {
            String sql = "SELECT u.id, u.username, u.email, u.role, " +
                         "sp.name AS personnel_name, sp.branch_id, sp.shift_time, " +
                         "b.name AS branch " +
                         "FROM users u " +
                         "LEFT JOIN security_personnel sp ON u.id = sp.user_id " +
                         "LEFT JOIN branches b ON sp.branch_id = b.id " +
                         "ORDER BY u.username";
            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Get All Personnel ----------------
    public static ResultSet getAllPersonnel() {
        connection();
        try {
            String sql = "SELECT u.username, u.email, b.name AS branch, sp.shift_time, sp.name AS personnel_name " +
                         "FROM users u " +
                         "JOIN security_personnel sp ON u.id = sp.user_id " +
                         "JOIN branches b ON sp.branch_id = b.id";

            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Get Branches ----------------
    public static ResultSet getBranches() {
        connection();
        try {
            String sql = "SELECT id, name FROM branches";
            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Login ----------------
    public static String getUserRole(String username, String password) {
        connection();
        try {
            String hash = universalManager.hashPassword(password);

            String sql = "SELECT role FROM users WHERE username=? AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, hash);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("role");

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Dashboard Counts ----------------
    public static int getTotalPersonnel() {
        connection();
        try {
            String sql = "SELECT COUNT(*) FROM security_personnel";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static int getTotalBranches() {
        connection();
        try {
            String sql = "SELECT COUNT(*) FROM branches";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static int getTotalReports() {
        connection();
        try {
            String sql = "SELECT COUNT(*) FROM shift_checks";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static int getTotalIncidents() {
        connection();
        try {
            String sql = "SELECT COUNT(*) FROM shift_checks WHERE status='NOT_OK'";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ---------------- Chart Data ----------------
    public static ResultSet getReportsByDate() {
        connection();
        try {
            String sql = "SELECT DATE(check_date) AS date, COUNT(*) AS total FROM shift_checks GROUP BY DATE(check_date)";
            PreparedStatement ps = con.prepareStatement(sql);
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
        connection();
        try {
            String sql = "SELECT b.name AS branch_name, COUNT(s.id) AS total " +
                         "FROM shift_checks s " +
                         "JOIN security_personnel sp ON s.personnel_id = sp.id " +
                         "JOIN branches b ON sp.branch_id = b.id " +
                         "WHERE s.status='NOT_OK' " +
                         "GROUP BY b.name";

            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Attendance Management ----------------
    public static boolean recordAttendance(int userId, double latitude, double longitude, String selfiePath) {
        connection();
        try {
            String sql = "INSERT INTO attendance(user_id, latitude, longitude, selfie_path) VALUES(?,?,?,?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setDouble(2, latitude);
            ps.setDouble(3, longitude);
            ps.setString(4, selfiePath);
            
            int result = ps.executeUpdate();
            con.close();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static ResultSet getAttendanceByUser(int userId) {
        connection();
        try {
            String sql = "SELECT * FROM attendance WHERE user_id = ? ORDER BY scan_time DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ResultSet getAllAttendance() {
        connection();
        try {
            String sql = "SELECT a.*, u.username, u.role " +
                         "FROM attendance a " +
                         "JOIN users u ON a.user_id = u.id " +
                         "ORDER BY a.scan_time DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Shift Management ----------------
    public static boolean createShift(int userId, String startTime, String endTime) {
        connection();
        try {
            String sql = "INSERT INTO shifts(user_id, start_time, end_time) VALUES(?,?,?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, startTime);
            ps.setString(3, endTime);
            
            int result = ps.executeUpdate();
            con.close();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static ResultSet getShiftsByUser(int userId) {
        connection();
        try {
            String sql = "SELECT * FROM shifts WHERE user_id = ? ORDER BY start_time DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ResultSet getAllShifts() {
        connection();
        try {
            String sql = "SELECT s.*, u.username, u.role " +
                         "FROM shifts s " +
                         "JOIN users u ON s.user_id = u.id " +
                         "ORDER BY s.start_time DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------------- Enhanced Reports ----------------
    public static ResultSet getDetailedReports() {
        connection();
        try {
            String sql = "SELECT sc.id, u.username, u.email, u.role, " +
                         "b.name AS branch, sp.name AS personnel_name, sp.shift_time, " +
                         "ci.item_name, sc.status, sc.reason, sc.check_time, sc.check_date " +
                         "FROM shift_checks sc " +
                         "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                         "JOIN users u ON sp.user_id = u.id " +
                         "JOIN branches b ON sp.branch_id = b.id " +
                         "JOIN checklist_items ci ON sc.item_id = ci.id " +
                         "ORDER BY sc.check_time DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static boolean updateShiftCheck(int checkId, String status, String reason) {
        connection();
        try {
            String sql = "UPDATE shift_checks SET status = ?, reason = ? WHERE id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, reason);
            ps.setInt(3, checkId);
            
            int result = ps.executeUpdate();
            con.close();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ---------------- Debug Methods ----------------
    public static ResultSet getAllShiftChecksRaw() {
        connection();
        try {
            String sql = "SELECT * FROM shift_checks ORDER BY check_time DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ResultSet getShiftChecksWithJoins() {
        connection();
        try {
            String sql = "SELECT sc.*, u.username, b.name AS branch, ci.item_name, " +
                         "sp.name AS personnel_name " +
                         "FROM shift_checks sc " +
                         "LEFT JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                         "LEFT JOIN users u ON sp.user_id = u.id " +
                         "LEFT JOIN branches b ON sp.branch_id = b.id " +
                         "LEFT JOIN checklist_items ci ON sc.item_id = ci.id " +
                         "ORDER BY sc.check_time DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            return ps.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
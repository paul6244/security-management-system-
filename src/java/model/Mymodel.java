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
        try (Connection conn = DatabaseConfig.getConnection()) {
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
        try (Connection conn = DatabaseConfig.getConnection()) {
            String hash = universalManager.hashPassword(password);

            String sql = "SELECT role FROM users WHERE username=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, hash);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("role");

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
}

package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/GetPersonnelDetails")
public class GetPersonnelDetails extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String username = request.getParameter("username");
        
        try {
            String detailsHtml = getPersonnelDetailsHtml(username);
            out.print(detailsHtml);
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        } finally {
            out.close();
        }
    }
    
    private String getPersonnelDetailsHtml(String username) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        StringBuilder html = new StringBuilder();
        
        try {
            // Get database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/securitymanagementsystem", "root", "");
            
            // Get user details
            String userSql = "SELECT u.id, u.username, u.email, u.role, " +
                            "u.created_at FROM users WHERE username = ?";
            ps = conn.prepareStatement(userSql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                return "error: Personnel not found";
            }
            
            int userId = rs.getInt("id");
            String email = rs.getString("email");
            String role = rs.getString("role");
            String createdAt = rs.getString("created_at");
            
            rs.close();
            ps.close();
            
            // Get personnel details
            String personnelSql = "SELECT sp.name, sp.branch_id, sp.shift_time, " +
                                 "b.name AS branch_name FROM security_personnel sp " +
                                 "LEFT JOIN branches b ON sp.branch_id = b.id " +
                                 "WHERE sp.user_id = ?";
            ps = conn.prepareStatement(personnelSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            
            String personnelName = "";
            String branchName = "Not Assigned";
            String shiftTime = "Not Set";
            
            if (rs.next()) {
                personnelName = rs.getString("name") != null ? rs.getString("name") : "";
                branchName = rs.getString("branch_name") != null ? rs.getString("branch_name") : "Not Assigned";
                shiftTime = rs.getString("shift_time") != null ? rs.getString("shift_time") : "Not Set";
            }
            
            rs.close();
            ps.close();
            
            // Get statistics
            String statsSql = "SELECT " +
                            "COUNT(*) as total_checks, " +
                            "COUNT(CASE WHEN status = 'OK' THEN 1 END) as ok_checks, " +
                            "COUNT(CASE WHEN status = 'Not ok' THEN 1 END) as not_ok_checks, " +
                            "MAX(check_time) as last_check " +
                            "FROM shift_checks WHERE personnel_id = ?";
            ps = conn.prepareStatement(statsSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            
            int totalChecks = 0;
            int okChecks = 0;
            int notOkChecks = 0;
            String lastCheck = "No checks recorded";
            
            if (rs.next()) {
                totalChecks = rs.getInt("total_checks");
                okChecks = rs.getInt("ok_checks");
                notOkChecks = rs.getInt("not_ok_checks");
                lastCheck = rs.getString("last_check") != null ? rs.getString("last_check") : "No checks recorded";
            }
            
            rs.close();
            ps.close();
            
            // Build HTML response
            html.append("<div style='display: grid; grid-template-columns: 1fr 1fr; gap: 20px;'>");
            
            // Personal Information
            html.append("<div style='background: #f8f9fa; padding: 20px; border-radius: 8px;'>");
            html.append("<h4 style='color: #2c3e50; margin-bottom: 15px;'>👤 Personal Information</h4>");
            html.append("<table style='width: 100%;'>");
            html.append("<tr><td style='font-weight: bold; padding: 5px;'>Username:</td><td>").append(username).append("</td></tr>");
            html.append("<tr><td style='font-weight: bold; padding: 5px;'>Full Name:</td><td>").append(personnelName).append("</td></tr>");
            html.append("<tr><td style='font-weight: bold; padding: 5px;'>Email:</td><td>").append(email).append("</td></tr>");
            html.append("<tr><td style='font-weight: bold; padding: 5px;'>Role:</td><td>").append(formatRole(role)).append("</td></tr>");
            html.append("<tr><td style='font-weight: bold; padding: 5px;'>Member Since:</td><td>").append(formatDate(createdAt)).append("</td></tr>");
            html.append("</table>");
            html.append("</div>");
            
            // Work Information
            html.append("<div style='background: #f8f9fa; padding: 20px; border-radius: 8px;'>");
            html.append("<h4 style='color: #2c3e50; margin-bottom: 15px;'>💼 Work Information</h4>");
            html.append("<table style='width: 100%;'>");
            html.append("<tr><td style='font-weight: bold; padding: 5px;'>Branch:</td><td>").append(branchName).append("</td></tr>");
            html.append("<tr><td style='font-weight: bold; padding: 5px;'>Shift Time:</td><td>").append(shiftTime).append("</td></tr>");
            html.append("<tr><td style='font-weight: bold; padding: 5px;'>Status:</td><td><span style='background: #d4edda; color: #155724; padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: bold;'>Active</span></td></tr>");
            html.append("</table>");
            html.append("</div>");
            
            // Performance Statistics
            html.append("<div style='background: #f8f9fa; padding: 20px; border-radius: 8px; grid-column: 1 / -1;'>");
            html.append("<h4 style='color: #2c3e50; margin-bottom: 15px;'>📊 Performance Statistics</h4>");
            html.append("<div style='display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; text-align: center;'>");
            
            html.append("<div style='background: white; padding: 15px; border-radius: 8px; border-left: 4px solid #3498db;'>");
            html.append("<div style='font-size: 24px; font-weight: bold; color: #3498db;'>").append(totalChecks).append("</div>");
            html.append("<div style='color: #666; font-size: 14px;'>Total Checks</div>");
            html.append("</div>");
            
            html.append("<div style='background: white; padding: 15px; border-radius: 8px; border-left: 4px solid #27ae60;'>");
            html.append("<div style='font-size: 24px; font-weight: bold; color: #27ae60;'>").append(okChecks).append("</div>");
            html.append("<div style='color: #666; font-size: 14px;'>OK Checks</div>");
            html.append("</div>");
            
            html.append("<div style='background: white; padding: 15px; border-radius: 8px; border-left: 4px solid #e74c3c;'>");
            html.append("<div style='font-size: 24px; font-weight: bold; color: #e74c3c;'>").append(notOkChecks).append("</div>");
            html.append("<div style='color: #666; font-size: 14px;'>Issues</div>");
            html.append("</div>");
            
            double successRate = totalChecks > 0 ? (double) okChecks / totalChecks * 100 : 0;
            html.append("<div style='background: white; padding: 15px; border-radius: 8px; border-left: 4px solid #f39c12;'>");
            html.append("<div style='font-size: 24px; font-weight: bold; color: #f39c12;'>").append(String.format("%.1f%%", successRate)).append("</div>");
            html.append("<div style='color: #666; font-size: 14px;'>Success Rate</div>");
            html.append("</div>");
            
            html.append("</div>");
            html.append("<div style='margin-top: 15px; padding-top: 15px; border-top: 1px solid #ddd;'>");
            html.append("<strong>Last Check:</strong> ").append(formatDateTime(lastCheck));
            html.append("</div>");
            html.append("</div>");
            
            html.append("</div>");
            
            return html.toString();
            
        } catch (Exception e) {
            e.printStackTrace();
            return "error: " + e.getMessage();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private String formatRole(String role) {
        if (role == null) return "Unknown";
        switch (role) {
            case "admin":
                return "Administrator";
            case "security_officer":
                return "Security Officer";
            default:
                return role.replace("_", " ").substring(0, 1).toUpperCase() + role.substring(1);
        }
    }
    
    private String formatDate(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) return "Unknown";
        try {
            // Simple date formatting - you can enhance this
            return dateStr.substring(0, 10);
        } catch (Exception e) {
            return dateStr;
        }
    }
    
    private String formatDateTime(String dateTimeStr) {
        if (dateTimeStr == null || dateTimeStr.equals("No checks recorded")) return dateTimeStr;
        try {
            // Simple datetime formatting
            return dateTimeStr.substring(0, 16).replace('T', ' ');
        } catch (Exception e) {
            return dateTimeStr;
        }
    }
}

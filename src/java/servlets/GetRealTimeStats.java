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
import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import config.DatabaseConfig;

@WebServlet("/GetRealTimeStats")
public class GetRealTimeStats extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        JSONObject stats = new JSONObject();
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            String username = request.getParameter("username");
            if (username == null) {
                username = (String) request.getSession().getAttribute("username");
            }
            
            if (username != null) {
                // Get user ID
                String userSql = "SELECT id FROM users WHERE username = ?";
                PreparedStatement userPs = con.prepareStatement(userSql);
                userPs.setString(1, username);
                ResultSet userRs = userPs.executeQuery();
                
                if(userRs.next()) {
                    int userId = userRs.getInt("id");
                    
                    // Get personnel ID
                    String personnelSql = "SELECT id FROM security_personnel WHERE user_id = ?";
                    PreparedStatement personnelPs = con.prepareStatement(personnelSql);
                    personnelPs.setInt(1, userId);
                    ResultSet personnelRs = personnelPs.executeQuery();
                    
                    if(personnelRs.next()) {
                        int personnelId = personnelRs.getInt("id");
                        
                        // Attendance stats
                        JSONObject attendance = new JSONObject();
                        
                        // Today's attendance
                        String todaySql = "SELECT COUNT(*) as count FROM shift_checks WHERE personnel_id = ? AND DATE(check_time) = CURDATE()";
                        PreparedStatement todayPs = con.prepareStatement(todaySql);
                        todayPs.setInt(1, personnelId);
                        ResultSet todayRs = todayPs.executeQuery();
                        
                        if(todayRs.next()) {
                            int todayCount = todayRs.getInt("count");
                            attendance.put("today", todayCount > 0 ? "Present" : "Absent");
                        }
                        todayRs.close();
                        todayPs.close();
                        
                        // Monthly attendance
                        String monthSql = "SELECT COUNT(*) as count FROM shift_checks WHERE personnel_id = ? AND MONTH(check_time) = MONTH(CURDATE()) AND YEAR(check_time) = YEAR(CURDATE())";
                        PreparedStatement monthPs = con.prepareStatement(monthSql);
                        monthPs.setInt(1, personnelId);
                        ResultSet monthRs = monthPs.executeQuery();
                        
                        if(monthRs.next()) {
                            attendance.put("monthly", monthRs.getInt("count") + " days");
                        }
                        monthRs.close();
                        monthPs.close();
                        
                        stats.put("attendance", attendance);
                        
                        // Shift status
                        JSONObject shiftStatus = new JSONObject();
                        String shiftSql = "SELECT status, check_time FROM shift_checks WHERE personnel_id = ? AND DATE(check_time) = CURDATE() ORDER BY check_time DESC LIMIT 1";
                        PreparedStatement shiftPs = con.prepareStatement(shiftSql);
                        shiftPs.setInt(1, personnelId);
                        ResultSet shiftRs = shiftPs.executeQuery();
                        
                        if(shiftRs.next()) {
                            String status = shiftRs.getString("status");
                            shiftStatus.put("status", status.equals("OK") ? "OK" : "NOT OK");
                            shiftStatus.put("message", status.equals("OK") ? "All checks completed" : "Issues found");
                        } else {
                            shiftStatus.put("status", "NOT OK");
                            shiftStatus.put("message", "No checks today");
                        }
                        shiftRs.close();
                        shiftPs.close();
                        
                        stats.put("shiftStatus", shiftStatus);
                        
                        // Checklist status
                        JSONObject checklist = new JSONObject();
                        String checklistSql = "SELECT status FROM shift_checks WHERE personnel_id = ? AND DATE(check_time) = CURDATE() ORDER BY check_time DESC LIMIT 1";
                        PreparedStatement checklistPs = con.prepareStatement(checklistSql);
                        checklistPs.setInt(1, personnelId);
                        ResultSet checklistRs = checklistPs.executeQuery();
                        
                        if(checklistRs.next()) {
                            String status = checklistRs.getString("status");
                            checklist.put("status", status.equals("OK") ? "OK" : "NOT OK");
                            checklist.put("message", status.equals("OK") ? "All items completed" : "Issues found");
                        } else {
                            checklist.put("status", "NOT OK");
                            checklist.put("message", "No checklist submitted");
                        }
                        checklistRs.close();
                        checklistPs.close();
                        
                        stats.put("checklist", checklist);
                        
                        // Performance
                        JSONObject performance = new JSONObject();
                        String performanceSql = "SELECT COUNT(*) as total, SUM(CASE WHEN status = 'OK' THEN 1 ELSE 0 END) as ok_checks FROM shift_checks WHERE personnel_id = ? AND DATE(check_time) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
                        PreparedStatement performancePs = con.prepareStatement(performanceSql);
                        performancePs.setInt(1, personnelId);
                        ResultSet performanceRs = performancePs.executeQuery();
                        
                        if(performanceRs.next()) {
                            int total = performanceRs.getInt("total");
                            int okChecks = performanceRs.getInt("ok_checks");
                            
                            if(total > 0) {
                                int performanceRate = (okChecks * 100) / total;
                                performance.put("rate", performanceRate + "%");
                                performance.put("message", "Success rate this week");
                            } else {
                                performance.put("rate", "N/A");
                                performance.put("message", "No data");
                            }
                        }
                        performanceRs.close();
                        performancePs.close();
                        
                        stats.put("performance", performance);
                        
                    } else {
                        stats.put("error", "No personnel record found");
                    }
                    personnelRs.close();
                    personnelPs.close();
                } else {
                    stats.put("error", "User not found");
                }
                userRs.close();
                userPs.close();
            } else {
                stats.put("error", "No username provided");
            }
            
            con.close();
            
        } catch(Exception e) {
            stats.put("error", e.getMessage());
        }
        
        out.print(stats.toJSONString());
        out.flush();
    }
}

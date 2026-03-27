package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.google.gson.Gson;

import config.DatabaseConfig;

@WebServlet("/GetFilteredReports")
public class GetFilteredReports extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        if(session.getAttribute("username") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not logged in");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String branch = request.getParameter("branch");
        String status = request.getParameter("status");

        // Debug: Log request parameters
        System.out.println("=== GetFilteredReports DEBUG ===");
        System.out.println("dateFrom: " + dateFrom);
        System.out.println("dateTo: " + dateTo);
        System.out.println("branch: " + branch);
        System.out.println("status: " + status);
        System.out.println("================================");

        List<ReportData> reports = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = DatabaseConfig.getConnection();
            System.out.println("Database connection established: " + (con != null));
            
            StringBuilder sql = new StringBuilder(
                "SELECT u.username, b.name AS branch, ci.item_name, " +
                "sc.status, sc.reason, sc.check_time " +
                "FROM shift_checks sc " +
                "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                "JOIN users u ON sp.user_id = u.id " +
                "JOIN branches b ON sp.branch_id = b.id " +
                "JOIN checklist_items ci ON sc.item_id = ci.id " +
                "WHERE 1=1");

            List<Object> params = new ArrayList<>();

            if(dateFrom != null && !dateFrom.trim().isEmpty()) {
                sql.append(" AND DATE(sc.check_time) >= ?");
                params.add(dateFrom.trim());
                System.out.println("Added dateFrom filter: " + dateFrom);
            }

            if(dateTo != null && !dateTo.trim().isEmpty()) {
                sql.append(" AND DATE(sc.check_time) <= ?");
                params.add(dateTo.trim());
                System.out.println("Added dateTo filter: " + dateTo);
            }

            if(branch != null && !branch.trim().isEmpty()) {
                sql.append(" AND b.id = ?");
                try {
                    params.add(Integer.parseInt(branch.trim()));
                    System.out.println("Added branch filter: " + branch);
                } catch(NumberFormatException e) {
                    System.out.println("Invalid branch ID: " + branch);
                    // Invalid branch ID, skip this filter
                }
            }

            if(status != null && !status.trim().isEmpty()) {
                sql.append(" AND sc.status = ?");
                params.add(status.trim());
                System.out.println("Added status filter: " + status);
            }

            sql.append(" ORDER BY sc.check_time DESC");
            System.out.println("Final SQL: " + sql.toString());
            System.out.println("Parameters count: " + params.size());

            ps = con.prepareStatement(sql.toString());
            
            for(int i = 0; i < params.size(); i++) {
                if(params.get(i) instanceof Integer) {
                    ps.setInt(i + 1, (Integer) params.get(i));
                } else {
                    ps.setString(i + 1, (String) params.get(i));
                }
            }

            rs = ps.executeQuery();
            System.out.println("Query executed, getting results...");

            int recordCount = 0;
            while(rs.next()) {
                recordCount++;
                ReportData report = new ReportData();
                report.username = rs.getString("username");
                report.branch = rs.getString("branch");
                report.itemName = rs.getString("item_name");
                report.status = rs.getString("status");
                report.reason = rs.getString("reason");
                
                Timestamp ts = rs.getTimestamp("check_time");
                if(ts != null) {
                    report.checkTime = ts.toString();
                } else {
                    report.checkTime = "";
                }
                
                reports.add(report);
                System.out.println("Record " + recordCount + ": " + report.username + ", " + report.branch + ", " + report.itemName + ", " + report.status);
            }

            System.out.println("Total records found: " + recordCount);

        } catch(SQLException e) {
            System.out.println("SQL Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + e.getMessage());
            return;
        } catch(Exception e) {
            System.out.println("General Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error: " + e.getMessage());
            return;
        } finally {
            // Proper resource cleanup
            try {
                if(rs != null) rs.close();
                if(ps != null) ps.close();
                if(con != null) con.close();
            } catch(SQLException e) {
                e.printStackTrace();
            }
        }

        // Convert to JSON and send response
        try {
            Gson gson = new Gson();
            String json = gson.toJson(reports);
            
            System.out.println("JSON Response: " + json);
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json);
        } catch(Exception e) {
            System.out.println("JSON Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "JSON serialization error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    // Inner class to represent report data
    public static class ReportData {
        public String username;
        public String branch;
        public String itemName;
        public String status;
        public String reason;
        public String checkTime;
    }
}

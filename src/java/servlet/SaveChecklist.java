package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.Enumeration;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SaveChecklist")
public class SaveChecklist extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        try {
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/securitymanagementsystem","root","");

            String username = (String) request.getSession().getAttribute("username");

            // GET user ID (same as StartShift)
            String sqlUser = "SELECT id FROM users WHERE username=?";
            PreparedStatement psUser = con.prepareStatement(sqlUser);
            psUser.setString(1, username);
            ResultSet rs = psUser.executeQuery();

            if(!rs.next()){
                response.getWriter().println("User not found");
                return;
            }

            int userId = rs.getInt("id");

            // Get personnel ID for checklist insertion
            String sqlPersonnel = "SELECT sp.id FROM security_personnel sp WHERE sp.user_id=?";
            PreparedStatement psPersonnel = con.prepareStatement(sqlPersonnel);
            psPersonnel.setInt(1, userId);
            ResultSet rsPersonnel = psPersonnel.executeQuery();

            if(!rsPersonnel.next()){
                response.getWriter().println("Personnel not found");
                return;
            }

            int personnelId = rsPersonnel.getInt("id");

            // Get current shift ID (using same userId as StartShift)
            String shiftSql = "SELECT id FROM shifts WHERE user_id = ? AND end_time IS NULL ORDER BY start_time DESC LIMIT 1";
            PreparedStatement shiftPs = con.prepareStatement(shiftSql);
            shiftPs.setInt(1, userId);  // Use userId, not personnelId
            ResultSet shiftRs = shiftPs.executeQuery();
            
            int shiftId = 0;
            if(shiftRs.next()) {
                shiftId = shiftRs.getInt("id");
                
                // Update shift to mark it as ended
                String updateShiftSql = "UPDATE shifts SET end_time = NOW() WHERE id = ?";
                PreparedStatement updatePs = con.prepareStatement(updateShiftSql);
                updatePs.setInt(1, shiftId);
                updatePs.executeUpdate();
                updatePs.close();
            } else {
                response.getWriter().println("No active shift found");
                return;
            }

            // Process checklist items
            Enumeration<String> params = request.getParameterNames();
            while(params.hasMoreElements()){
                String param = params.nextElement();

                if(param.startsWith("item_")){
                    int itemId = Integer.parseInt(param.split("_")[1]);
                    String status = request.getParameter(param);
                    String reason = request.getParameter("reason_" + itemId);

                    if("NOT_OK".equals(status) && (reason == null || reason.trim().isEmpty())){
                        response.getWriter().println("Provide reason for item " + itemId);
                        return;
                    }

                    if("OK".equals(status)){
                        reason = "";
                    }

                    try {
                        String sql = "INSERT INTO shift_checks(personnel_id,item_id,status,reason,check_time,check_date) VALUES(?,?,?,?,NOW(),NOW())";
                        PreparedStatement itemPs = con.prepareStatement(sql);
                        itemPs.setInt(1, personnelId);
                        itemPs.setInt(2, itemId);
                        itemPs.setString(3, status);
                        itemPs.setString(4, reason);
                        itemPs.executeUpdate();
                        itemPs.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            // Close all prepared statements
            if(psUser != null) psUser.close();
            if(shiftPs != null) shiftPs.close();
            if(con != null) con.close();
            
            // Redirect with success message
            response.sendRedirect("personnelDashboard.jsp?status=success&message=Shift ended successfully and checklist submitted!");

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("personnelDashboard.jsp?status=error&message=Error submitting checklist: " + e.getMessage());
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
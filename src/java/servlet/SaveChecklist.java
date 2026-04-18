package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.Enumeration;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import config.DatabaseConfig;

@WebServlet("/SaveChecklist")
public class SaveChecklist extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        try {
            Connection con = DatabaseConfig.getConnection();

            String username = (String) request.getSession().getAttribute("username");

            // GET user ID
            String sqlUser = "SELECT id FROM users WHERE username=?";
            PreparedStatement psUser = con.prepareStatement(sqlUser);
            psUser.setString(1, username);
            ResultSet rs = psUser.executeQuery();

            if(!rs.next()){
                response.sendRedirect("personnelDashboard.jsp?status=error&message=User not found");
                return;
            }

            int userId = rs.getInt("id");

            // Get personnel ID
            String sqlPersonnel = "SELECT id FROM security_personnel WHERE user_id=?";
            PreparedStatement psPersonnel = con.prepareStatement(sqlPersonnel);
            psPersonnel.setInt(1, userId);
            ResultSet rsPersonnel = psPersonnel.executeQuery();

            int personnelId = 0;
            if(!rsPersonnel.next()){
                response.sendRedirect("personnelDashboard.jsp?status=error&message=Personnel not found");
                return;
            }
            personnelId = rsPersonnel.getInt("id");

            // Get current shift ID
            String shiftSql = "SELECT id FROM shifts WHERE user_id = ? AND end_time IS NULL ORDER BY start_time DESC LIMIT 1";
            PreparedStatement shiftPs = con.prepareStatement(shiftSql);
            shiftPs.setInt(1, userId);
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
                // Create a new shift if no active shift exists
                String createShiftSql = "INSERT INTO shifts(user_id, start_time, end_time) VALUES(?, NOW(), NOW())";
                PreparedStatement createPs = con.prepareStatement(createShiftSql, PreparedStatement.RETURN_GENERATED_KEYS);
                createPs.setInt(1, userId);
                createPs.executeUpdate();
                
                ResultSet generatedKeys = createPs.getGeneratedKeys();
                if(generatedKeys.next()) {
                    shiftId = generatedKeys.getInt(1);
                }
                createPs.close();
            }
            shiftRs.close();
            shiftPs.close();

            // Process checklist items - ORIGINAL SIMPLE VERSION
            Enumeration<String> params = request.getParameterNames();
            int itemsProcessed = 0;
            
            while(params.hasMoreElements()){
                String param = params.nextElement();

                if(param.startsWith("item_")){
                    int itemId = Integer.parseInt(param.split("_")[1]);
                    String status = request.getParameter(param);
                    String reason = request.getParameter("reason_" + itemId);

                    if(status != null && !status.trim().isEmpty()){
                        
                        if(reason == null) reason = "";
                        if("OK".equals(status)) reason = "";
                        
                        try {
                            String sql = "INSERT INTO shift_checks(shift_id,personnel_id,item_id,status,reason,check_time) VALUES(?,?,?,?,?,NOW())";
                            PreparedStatement itemPs = con.prepareStatement(sql);
                            itemPs.setInt(1, shiftId); // Use actual shift ID
                            itemPs.setInt(2, personnelId);
                            itemPs.setInt(3, itemId);
                            itemPs.setString(4, status);
                            itemPs.setString(5, reason);
                            itemPs.executeUpdate();
                            itemPs.close();
                            itemsProcessed++;
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            }

            // Close connections
            if(psUser != null) psUser.close();
            if(psPersonnel != null) psPersonnel.close();
            if(con != null) con.close();
            
            if(itemsProcessed > 0) {
                response.sendRedirect("personnelDashboard.jsp?status=success&message=Shift ended successfully! " + itemsProcessed + " checklist items submitted.");
            } else {
                response.sendRedirect("personnelDashboard.jsp?status=error&message=No checklist items were processed. Please check your submission and try again.");
            }

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

package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SimpleTest")
public class SimpleTest extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        try {
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/securitymanagementsystem","root","");

            String username = (String) request.getSession().getAttribute("username");

            // Simple user check
            String sqlUser = "SELECT id FROM users WHERE username=?";
            PreparedStatement psUser = con.prepareStatement(sqlUser);
            psUser.setString(1, username);
            ResultSet rs = psUser.executeQuery();

            if(!rs.next()){
                response.sendRedirect("simpleTest.jsp?status=error&message=User not found: " + username);
                return;
            }

            int userId = rs.getInt("id");

            // Simple personnel check
            String sqlPersonnel = "SELECT id FROM security_personnel WHERE user_id=?";
            PreparedStatement psPersonnel = con.prepareStatement(sqlPersonnel);
            psPersonnel.setInt(1, userId);
            ResultSet rsPersonnel = psPersonnel.executeQuery();

            int personnelId = 0;
            if(!rsPersonnel.next()){
                response.sendRedirect("simpleTest.jsp?status=error&message=Personnel not found for user: " + username);
                return;
            }

            personnelId = rsPersonnel.getInt("id");

            // Process items - SUPER SIMPLE
            int itemsProcessed = 0;
            
            // Process item_1
            String status1 = request.getParameter("item_1");
            if(status1 != null && !status1.isEmpty()) {
                String sql = "INSERT INTO shift_checks(personnel_id,item_id,status,reason,check_time) VALUES(?,?,?,?,NOW())";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, personnelId);
                ps.setInt(2, 1);
                ps.setString(3, status1);
                ps.setString(4, "OK".equals(status1) ? "" : "Test reason");
                ps.executeUpdate();
                ps.close();
                itemsProcessed++;
            }
            
            // Process item_2
            String status2 = request.getParameter("item_2");
            if(status2 != null && !status2.isEmpty()) {
                String sql = "INSERT INTO shift_checks(personnel_id,item_id,status,reason,check_time) VALUES(?,?,?,?,NOW())";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, personnelId);
                ps.setInt(2, 2);
                ps.setString(3, status2);
                ps.setString(4, "OK".equals(status2) ? "" : "Test reason");
                ps.executeUpdate();
                ps.close();
                itemsProcessed++;
            }
            
            // Process item_3
            String status3 = request.getParameter("item_3");
            if(status3 != null && !status3.isEmpty()) {
                String sql = "INSERT INTO shift_checks(personnel_id,item_id,status,reason,check_time) VALUES(?,?,?,?,NOW())";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, personnelId);
                ps.setInt(2, 3);
                ps.setString(3, status3);
                ps.setString(4, "OK".equals(status3) ? "" : "Test reason");
                ps.executeUpdate();
                ps.close();
                itemsProcessed++;
            }

            con.close();
            
            if(itemsProcessed > 0) {
                response.sendRedirect("simpleTest.jsp?status=success&message=SUCCESS! " + itemsProcessed + " items processed. Simple test worked!");
            } else {
                response.sendRedirect("simpleTest.jsp?status=error&message=No items processed. Check form submission.");
            }

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("simpleTest.jsp?status=error&message=Database error: " + e.getMessage());
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

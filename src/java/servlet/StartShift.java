package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import config.DatabaseConfig;

@WebServlet("/StartShift")
public class StartShift extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        try {
            Connection con = DatabaseConfig.getConnection();

            String username = (String) request.getSession().getAttribute("username");

            // DEBUG
            System.out.println("Username: " + username);
            System.out.println("Looking for user ID for: " + username);

            // If not logged in
            if(username == null){
                response.getWriter().println("ERROR: User not logged in!");
                return;
            }

            // Check if user exists
            String checkUser = "SELECT id FROM users WHERE username=?";
            PreparedStatement checkPs = con.prepareStatement(checkUser);
            checkPs.setString(1, username);
            ResultSet rs = checkPs.executeQuery();

            if(!rs.next()){
                response.getWriter().println("ERROR: User not found in database!");
                return;
            }

            int userId = rs.getInt("id");
            System.out.println("Found user ID: " + userId);

            // Check for existing active shifts
            String checkActiveShift = "SELECT id, start_time FROM shifts WHERE user_id = ? AND end_time IS NULL";
            PreparedStatement activePs = con.prepareStatement(checkActiveShift);
            activePs.setInt(1, userId);
            ResultSet activeRs = activePs.executeQuery();
            
            if(activeRs.next()){
                System.out.println("Active shift found - ID: " + activeRs.getInt("id") + ", Start: " + activeRs.getTimestamp("start_time"));
                response.getWriter().println("ERROR: User already has an active shift!");
                response.getWriter().println("Please end current shift before starting a new one.");
                activeRs.close();
                return;
            }
            activeRs.close();

            // Insert shift
            String sql = "INSERT INTO shifts(user_id,start_time) VALUES(?, NOW())";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);

            int result = ps.executeUpdate();
            System.out.println("Shift insertion result: " + result);

            if(result > 0){
                System.out.println("Shift started successfully!");
                response.sendRedirect("personnelDashboard.jsp?status=success&message=Shift started successfully!");
            } else {
                response.getWriter().println("ERROR: Shift not inserted");
            }

            // Close resources
            ps.close();
            checkPs.close();
            rs.close();
            activePs.close();
            con.close();

        } catch(Exception e){
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}

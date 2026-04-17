package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import config.DatabaseConfig;

@WebServlet("/EndShift")
public class EndShift extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        try {
            Connection con = DatabaseConfig.getConnection();

            String username = (String) request.getSession().getAttribute("username");

            System.out.println("Ending shift for: " + username);

            if(username == null){
                response.getWriter().println("ERROR: User not logged in!");
                return;
            }

            // ✅ Get user ID
            String getUser = "SELECT id FROM users WHERE username=?";
            PreparedStatement ps1 = con.prepareStatement(getUser);
            ps1.setString(1, username);
            ResultSet rs = ps1.executeQuery();

            if(!rs.next()){
                response.getWriter().println("ERROR: User not found!");
                return;
            }

            int userId = rs.getInt("id");

            // End shift
            String sql = "UPDATE shifts SET end_time=NOW() WHERE user_id=? AND end_time IS NULL";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);

            int result = ps.executeUpdate();

            if(result > 0){
                System.out.println("Shift ended!");
                response.sendRedirect("personnelDashboard.jsp");
            } else {
                response.getWriter().println("No active shift found!");
            }

            // Close resources
            ps.close();
            ps1.close();
            rs.close();
            con.close();

        } catch(Exception e){
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}
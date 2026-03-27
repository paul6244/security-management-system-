package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import config.DatabaseConfig;

@WebServlet("/ResetSystemData")
public class ResetSystemData extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            // Reset shift_checks table
            String resetSql = "DELETE FROM shift_checks";
            PreparedStatement resetPs = con.prepareStatement(resetSql);
            int result = resetPs.executeUpdate();
            resetPs.close();
            
            con.close();
            
            out.println("<script>alert('System data reset successfully! All shift data has been cleared.'); window.location.href='settings.jsp';</script>");
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error resetting system data: " + e.getMessage() + "'); window.location.href='settings.jsp';</script>");
        }
    }
}

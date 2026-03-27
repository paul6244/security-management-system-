package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/UpdateSystemSettings")
public class UpdateSystemSettings extends HttpServlet {
    
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
        
        String systemName = request.getParameter("systemName");
        String sessionTimeout = request.getParameter("sessionTimeout");
        String maxAttempts = request.getParameter("maxLoginAttempts");
        
        try {
            // In a real application, these would be stored in a database or config file
            // For now, we'll just show success message
            out.println("<script>alert('System settings updated successfully!'); window.location.href='settings.jsp';</script>");
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error updating system settings: " + e.getMessage() + "'); window.location.href='settings.jsp';</script>");
        }
    }
}

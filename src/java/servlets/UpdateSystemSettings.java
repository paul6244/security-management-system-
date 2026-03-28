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
        
        // Validate CSRF token
        String sessionToken = (String) session.getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");
        
        if (sessionToken == null || !sessionToken.equals(requestToken)) {
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Invalid request - please try again");
            return;
        }
        
        String systemName = request.getParameter("systemName");
        String sessionTimeout = request.getParameter("sessionTimeout");
        String maxAttempts = request.getParameter("maxLoginAttempts");
        String emailNotifications = request.getParameter("emailNotifications");
        
        // For demonstration, we'll just show success message
        // In a real application, you'd store these in a system settings table
        
        boolean emailNotifsEnabled = (emailNotifications != null);
        
        System.out.println("Updated system settings:");
        System.out.println("System Name: " + systemName);
        System.out.println("Session Timeout: " + sessionTimeout);
        System.out.println("Max Login Attempts: " + maxAttempts);
        System.out.println("Email Notifications: " + emailNotifsEnabled);
        
        response.sendRedirect("securityOfficerSettings.jsp?success=1&message=System settings updated successfully!");
    }
}

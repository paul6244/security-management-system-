package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/UpdateDashboardSettings")
public class UpdateDashboardSettings extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
<<<<<<< HEAD
        // Validate CSRF token
        String sessionToken = (String) request.getSession().getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");
        
        if (sessionToken == null || !sessionToken.equals(requestToken)) {
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Invalid request - please try again");
            return;
        }
=======
        String username = (String) request.getSession().getAttribute("username");
>>>>>>> a2ae55f67fdb2960dceeb77213e859a83ba787a0
        String dashboardTheme = request.getParameter("dashboardTheme");
        String refreshRate = request.getParameter("refreshRate");
        String showCharts = request.getParameter("showCharts");
        String showNotifications = request.getParameter("showNotifications");
        
        // For demonstration, we'll just show success message
        // In a real application, you'd store these preferences in a separate table
        
        boolean chartsEnabled = (showCharts != null);
        boolean notificationsEnabled = (showNotifications != null);
        
        try {
            // Simulate processing
            Thread.sleep(500);
            
            response.sendRedirect("securityOfficerSettings.jsp?success=1&message=Dashboard preferences updated successfully!");
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Error updating dashboard settings");
        }
    }
}

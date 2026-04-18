package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/UpdateNotificationSettings")
public class UpdateNotificationSettings extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = (String) request.getSession().getAttribute("username");
        String emailAlerts = request.getParameter("emailAlerts");
        String shiftReminders = request.getParameter("shiftReminders");
        String reportUpdates = request.getParameter("reportUpdates");
        String systemUpdates = request.getParameter("systemUpdates");
        String reportFrequency = request.getParameter("reportFrequency");
        
        // For demonstration, we'll just show success message
        // In a real application, you'd store these preferences in a separate table
        
        boolean emailAlertsEnabled = (emailAlerts != null);
        boolean shiftRemindersEnabled = (shiftReminders != null);
        boolean reportUpdatesEnabled = (reportUpdates != null);
        boolean systemUpdatesEnabled = (systemUpdates != null);
        
        try {
            // Simulate processing
            Thread.sleep(500);
            
            response.sendRedirect("securityOfficerSettings.jsp?success=1&message=Notification preferences updated successfully!");
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Error updating notification settings");
        }
    }
}

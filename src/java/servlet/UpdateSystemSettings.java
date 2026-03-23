package servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateSystemSettings")
public class UpdateSystemSettings extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        
        // Check if user is admin
        String role = (String) session.getAttribute("role");
        if(!"admin".equals(role)) {
            session.setAttribute("settingsError", "Access denied. Admin privileges required.");
            response.sendRedirect("settings.jsp");
            return;
        }

        String systemName = request.getParameter("systemName");
        String sessionTimeout = request.getParameter("sessionTimeout");
        String maxLoginAttempts = request.getParameter("maxLoginAttempts");
        String emailNotifications = request.getParameter("emailNotifications");

        try {
            // Validate inputs
            if(systemName == null || systemName.trim().isEmpty()) {
                session.setAttribute("settingsError", "System name is required.");
                response.sendRedirect("settings.jsp");
                return;
            }

            // In a real application, you would save these to a database or config file
            // For now, we'll just simulate the update
            
            // You could store these in application scope or database
            getServletContext().setAttribute("systemName", systemName);
            getServletContext().setAttribute("sessionTimeout", sessionTimeout);
            getServletContext().setAttribute("maxLoginAttempts", maxLoginAttempts);
            getServletContext().setAttribute("emailNotifications", emailNotifications);

            session.setAttribute("settingsSuccess", "System settings updated successfully!");

        } catch(Exception e) {
            e.printStackTrace();
            session.setAttribute("settingsError", "An error occurred while updating system settings.");
        }

        response.sendRedirect("settings.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

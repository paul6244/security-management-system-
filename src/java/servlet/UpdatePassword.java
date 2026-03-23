package servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.Mymodel;
import utility.universalManager;

@WebServlet("/UpdatePassword")
public class UpdatePassword extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            // Validate inputs
            if(currentPassword == null || newPassword == null || confirmPassword == null ||
                currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
                session.setAttribute("settingsError", "All password fields are required.");
                response.sendRedirect("settings.jsp");
                return;
            }

            // Validate password confirmation
            if(!newPassword.equals(confirmPassword)) {
                session.setAttribute("settingsError", "New password and confirm password do not match.");
                response.sendRedirect("settings.jsp");
                return;
            }

            // Validate password length
            if(newPassword.length() < 6) {
                session.setAttribute("settingsError", "Password must be at least 6 characters long.");
                response.sendRedirect("settings.jsp");
                return;
            }

            // Verify current password
            String currentRole = Mymodel.getUserRole(username, currentPassword);
            if(currentRole == null) {
                session.setAttribute("settingsError", "Current password is incorrect.");
                response.sendRedirect("settings.jsp");
                return;
            }

            // Update password in database
            boolean updated = Mymodel.updateUserPassword(username, newPassword);
            
            if(updated) {
                session.setAttribute("settingsSuccess", "Password updated successfully!");
            } else {
                session.setAttribute("settingsError", "Failed to update password. Please try again.");
            }

        } catch(Exception e) {
            e.printStackTrace();
            session.setAttribute("settingsError", "An error occurred while updating password.");
        }

        response.sendRedirect("settings.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

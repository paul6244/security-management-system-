package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import config.DatabaseConfig;

@WebServlet("/RegisterSecurityPersonnel")
public class RegisterSecurityPersonnel extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get form parameters
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String branchId = request.getParameter("branch");
        String shiftTime = request.getParameter("shiftTime");
        String employeeId = request.getParameter("employeeId");
        String address = request.getParameter("address");
        String emergencyContact = request.getParameter("emergencyContact");
        
        Connection con = null;
        try {
            con = DatabaseConfig.getConnection();
            
            // First, create user account
            String createUserSql = "INSERT INTO users (username, password, email, role) VALUES (?, ?, ?, 'security_officer')";
            PreparedStatement userPs = con.prepareStatement(createUserSql, PreparedStatement.RETURN_GENERATED_KEYS);
            userPs.setString(1, username);
            userPs.setString(2, password); // In production, hash this password
            userPs.setString(3, email);
            
            int userResult = userPs.executeUpdate();
            
            // Get the generated user ID
            int userId = -1;
            ResultSet generatedKeys = userPs.getGeneratedKeys();
            if (generatedKeys.next()) {
                userId = generatedKeys.getInt(1);
            }
            
            userPs.close();
            
            if (userResult > 0 && userId > 0) {
                // Now create security personnel record
                String createPersonnelSql = "INSERT INTO security_personnel (user_id, name, email, branch_id, shift_time, employee_id, address, emergency_contact, phone) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement personnelPs = con.prepareStatement(createPersonnelSql);
                personnelPs.setInt(1, userId);
                personnelPs.setString(2, fullName);
                personnelPs.setString(3, email);
                personnelPs.setInt(4, Integer.parseInt(branchId));
                personnelPs.setString(5, shiftTime);
                personnelPs.setString(6, employeeId);
                personnelPs.setString(7, address);
                personnelPs.setString(8, emergencyContact);
                personnelPs.setString(9, phone);
                
                int personnelResult = personnelPs.executeUpdate();
                personnelPs.close();
                
                if (personnelResult > 0) {
                    response.sendRedirect("admin.jsp?success=1&message=Security personnel registered successfully!");
                } else {
                    response.sendRedirect("admin.jsp?error=1&message=Failed to register security personnel");
                }
            } else {
                response.sendRedirect("admin.jsp?error=1&message=Failed to create user account");
            }
            
            con.close();
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?error=1&message=Database error occurred: " + e.getMessage());
        }
    }
}

package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import config.DatabaseConfig;

@WebServlet("/StaffRegistration")
public class StaffRegistration extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String department = request.getParameter("department");
        String position = request.getParameter("position");
        String employeeId = request.getParameter("employeeId");
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            // Check if email already exists
            String checkSql = "SELECT COUNT(*) FROM staff_registration WHERE email = ?";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setString(1, email);
            ResultSet rs = checkPs.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("<script>alert('Email already registered!'); window.location.href='staffRegistration.jsp';</script>");
            } else {
                // Insert new staff registration
                String insertSql = "INSERT INTO staff_registration (full_name, email, phone, department, position, employee_id) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement insertPs = con.prepareStatement(insertSql);
                insertPs.setString(1, fullName);
                insertPs.setString(2, email);
                insertPs.setString(3, phone);
                insertPs.setString(4, department);
                insertPs.setString(5, position);
                insertPs.setString(6, employeeId);
                
                int result = insertPs.executeUpdate();
                
                if (result > 0) {
                    out.println("<script>alert('Staff registered successfully!'); window.location.href='staffRegistration.jsp';</script>");
                } else {
                    out.println("<script>alert('Error registering staff. Please try again.'); window.location.href='staffRegistration.jsp';</script>");
                }
                insertPs.close();
            }
            
            rs.close();
            checkPs.close();
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Database error: " + e.getMessage() + "'); window.location.href='staffRegistration.jsp';</script>");
        }
    }
}

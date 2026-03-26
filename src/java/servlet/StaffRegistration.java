package servlet;

import java.io.*;
import java.sql.*;
import java.util.Base64;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import config.DatabaseConfig;

@WebServlet("/StaffRegistration")
public class StaffRegistration extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws IOException {

        try {
            // Retrieve form parameters
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String department = request.getParameter("department");
            String position = request.getParameter("position");
            String employeeId = request.getParameter("employeeId");
            String officeLocation = request.getParameter("officeLocation");
            String address = request.getParameter("address");
            String selfie = request.getParameter("selfie");

            // Validate required fields
            if(firstName == null || firstName.trim().isEmpty() ||
               lastName == null || lastName.trim().isEmpty() ||
               email == null || email.trim().isEmpty() ||
               phone == null || phone.trim().isEmpty() ||
               department == null || department.trim().isEmpty() ||
               position == null || position.trim().isEmpty() ||
               employeeId == null || employeeId.trim().isEmpty()) {
                
                response.sendRedirect("staffRegistration.jsp?error=missing_fields");
                return;
            }

            // Validate selfie is captured
            if(selfie == null || selfie.trim().isEmpty()) {
                response.sendRedirect("staffRegistration.jsp?error=missing_selfie");
                return;
            }

            // Save selfie image
            String selfiePath = saveSelfieImage(selfie, employeeId);

            Connection con = DatabaseConfig.getConnection();

            // Check if email already exists
            PreparedStatement checkEmailPs = con.prepareStatement(
                "SELECT COUNT(*) FROM staff_registration WHERE email = ?");
            checkEmailPs.setString(1, email);
            ResultSet emailRs = checkEmailPs.executeQuery();
            if(emailRs.next() && emailRs.getInt(1) > 0) {
                response.sendRedirect("staffRegistration.jsp?error=email_exists");
                return;
            }
            emailRs.close();
            checkEmailPs.close();

            // Check if employee ID already exists
            PreparedStatement checkIdPs = con.prepareStatement(
                "SELECT COUNT(*) FROM staff_registration WHERE employee_id = ?");
            checkIdPs.setString(1, employeeId);
            ResultSet idRs = checkIdPs.executeQuery();
            if(idRs.next() && idRs.getInt(1) > 0) {
                response.sendRedirect("staffRegistration.jsp?error=employee_id_exists");
                return;
            }
            idRs.close();
            checkIdPs.close();

            // Insert staff registration
            String sql = "INSERT INTO staff_registration (first_name, last_name, email, phone, department, position, employee_id, office_location, address, selfie_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            
            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, department);
            ps.setString(6, position);
            ps.setString(7, employeeId);
            ps.setString(8, officeLocation);
            ps.setString(9, address);
            ps.setString(10, selfiePath);

            int result = ps.executeUpdate();
            ps.close();
            con.close();

            if(result > 0) {
                response.sendRedirect("staffRegistration.jsp?success=1");
            } else {
                response.sendRedirect("staffRegistration.jsp?error=registration_failed");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("staffRegistration.jsp?error=system_error");
        }
    }

    private String saveSelfieImage(String selfieData, String employeeId) {
        try {
            // Extract base64 data
            String base64Image = selfieData.split(",")[1];
            byte[] imageBytes = Base64.getDecoder().decode(base64Image);

            // Create filename with timestamp
            String fileName = "staff_" + employeeId + "_" + System.currentTimeMillis() + ".png";
            
            // Define path (adjust according to your server setup)
            String uploadPath = "C:/xampp/tomcat/webapps/SecurityManagementSystem/staff_photos/";
            
            // Create directory if it doesn't exist
            java.io.File uploadDir = new java.io.File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Save file
            java.io.File imageFile = new java.io.File(uploadPath + fileName);
            try (FileOutputStream fos = new FileOutputStream(imageFile)) {
                fos.write(imageBytes);
            }

            return "staff_photos/" + fileName;

        } catch(Exception e) {
            e.printStackTrace();
            return "";
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doPost(request, response);
    }
}

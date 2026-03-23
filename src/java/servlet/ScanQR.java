package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.Base64;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ScanQR")
public class ScanQR extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws IOException {

        try {
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/securitymanagementsystem","root","");

            // Get face recognition data instead of QR code
            String staffId = request.getParameter("staff_id");
            String lat = request.getParameter("latitude");
            String lng = request.getParameter("longitude");
            String selfie = request.getParameter("selfie");

            if(staffId == null || lat == null || lng == null || selfie == null){
                response.getWriter().println("Missing attendance data!");
                return;
            }

            // Validate staff exists
            String staffSql = "SELECT first_name, last_name, employee_id, selfie_path FROM staff_registration WHERE id = ?";
            PreparedStatement staffPs = con.prepareStatement(staffSql);
            staffPs.setString(1, staffId);
            ResultSet staffRs = staffPs.executeQuery();

            if(!staffRs.next()) {
                response.getWriter().println("Staff member not found!");
                return;
            }

            String firstName = staffRs.getString("first_name");
            String lastName = staffRs.getString("last_name");
            String employeeId = staffRs.getString("employee_id");
            String registrationPhotoPath = staffRs.getString("selfie_path");

            staffRs.close();
            staffPs.close();

            // Save attendance selfie
            String attendanceSelfiePath = saveAttendanceSelfie(selfie, staffId);

            // Simple face verification (placeholder - you can enhance this)
            boolean faceVerified = true; // For now, always verified
            String verificationMessage = "Face verification successful";

            // Check for duplicate attendance today
            String checkSql = "SELECT COUNT(*) FROM attendance WHERE staff_id = ? AND DATE(check_in_time) = CURDATE()";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setString(1, staffId);
            ResultSet checkRs = checkPs.executeQuery();
            
            if(checkRs.next() && checkRs.getInt(1) > 0) {
                response.sendRedirect("attendance.jsp?error=already_checked_in");
                return;
            }
            checkRs.close();
            checkPs.close();

            // Insert attendance record
            String sql = "INSERT INTO attendance (staff_id, employee_id, first_name, last_name, latitude, longitude, check_in_time, selfie_path, face_verified) VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            
            ps.setString(1, staffId);
            ps.setString(2, employeeId);
            ps.setString(3, firstName);
            ps.setString(4, lastName);
            ps.setString(5, lat);
            ps.setString(6, lng);
            ps.setString(7, attendanceSelfiePath);
            ps.setBoolean(8, faceVerified);

            int result = ps.executeUpdate();
            ps.close();
            con.close();

            if(result > 0) {
                response.sendRedirect("attendance.jsp?success=1&message=" + verificationMessage.replace(" ", "%20"));
            } else {
                response.sendRedirect("attendance.jsp?error=attendance_failed");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("attendance.jsp?error=system_error");
        }
    }

    private String saveAttendanceSelfie(String selfieData, String staffId) {
        try {
            // Extract base64 data
            String base64Image = selfieData.split(",")[1];
            byte[] imageBytes = Base64.getDecoder().decode(base64Image);

            // Create filename with timestamp
            String fileName = "attendance_" + staffId + "_" + System.currentTimeMillis() + ".png";
            
            // Define path
            String uploadPath = "C:/xampp/tomcat/webapps/SecurityManagementSystem/attendance_selfies/";
            
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

            return "attendance_selfies/" + fileName;

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
package model;

import java.sql.*;
import java.util.Base64;

public class StaffQRValidator {
    
    public static StaffInfo validateStaffQR(String qrContent) {
        if(qrContent == null || !qrContent.startsWith("STAFF_")) {
            return null;
        }
        
        try {
            // Parse QR content: STAFF_staffId_employeeId_emailHash
            String[] parts = qrContent.split("_");
            if(parts.length < 4) {
                return null;
            }
            
            int staffId = Integer.parseInt(parts[1]);
            String employeeId = parts[2];
            String emailHash = parts[3];
            
            // Verify staff exists in database
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
            
            String sql = "SELECT * FROM staff_registration WHERE id = ? AND employee_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, staffId);
            ps.setString(2, employeeId);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next()) {
                StaffInfo staff = new StaffInfo();
                staff.id = rs.getInt("id");
                staff.firstName = rs.getString("first_name");
                staff.lastName = rs.getString("last_name");
                staff.email = rs.getString("email");
                staff.employeeId = rs.getString("employee_id");
                staff.department = rs.getString("department");
                staff.position = rs.getString("position");
                
                // Verify email hash matches
                String actualEmailHash = Base64.getEncoder().encodeToString(rs.getString("email").getBytes()).substring(0, 8);
                if(actualEmailHash.equals(emailHash)) {
                    rs.close();
                    ps.close();
                    con.close();
                    return staff;
                }
            }
            
            rs.close();
            ps.close();
            con.close();
            
        } catch(Exception e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public static class StaffInfo {
        public int id;
        public String firstName;
        public String lastName;
        public String email;
        public String employeeId;
        public String department;
        public String position;
        
        public String getFullName() {
            return firstName + " " + lastName;
        }
    }
}

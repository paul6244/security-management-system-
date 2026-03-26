package servlet;

import java.io.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import config.DatabaseConfig;

@WebServlet("/GetStaff")
public class GetStaff extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            String sql = "SELECT id, first_name, last_name, employee_id, selfie_path FROM staff_registration ORDER BY first_name, last_name";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            StringBuilder json = new StringBuilder();
            json.append("[");
            
            boolean first = true;
            while(rs.next()) {
                if(!first) {
                    json.append(",");
                }
                
                int id = rs.getInt("id");
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                String employeeId = rs.getString("employee_id");
                String selfiePath = rs.getString("selfie_path");
                String fullName = firstName + " " + lastName;
                
                json.append("{");
                json.append("\"id\":").append(id).append(",");
                json.append("\"name\":\"").append(fullName.replace("\"", "\\\"")).append(" (").append(employeeId.replace("\"", "\\\"")).append(")\",");
                json.append("\"employeeId\":\"").append(employeeId.replace("\"", "\\\"")).append("\",");
                json.append("\"selfiePath\":\"").append(selfiePath != null ? selfiePath.replace("\"", "\\\"") : "").append("\"");
                json.append("}");
                
                first = false;
            }
            
            json.append("]");
            
            rs.close();
            ps.close();
            con.close();
            
            response.getWriter().write(json.toString());
            
        } catch(Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Unable to load staff data\"}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

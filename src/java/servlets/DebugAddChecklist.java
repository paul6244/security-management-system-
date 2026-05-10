package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import config.DatabaseConfig;

@WebServlet("/DebugAddChecklist")
public class DebugAddChecklist extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String itemName = request.getParameter("itemName");
        String branchId = request.getParameter("branchId");
        
        if (itemName == null || itemName.trim().isEmpty()) {
            itemName = "Test Item";
        }
        if (branchId == null || branchId.trim().isEmpty()) {
            branchId = "1";
        }
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            out.println("<h2>Debug Add Checklist Item</h2>");
            out.println("<p>Item Name: " + itemName + "</p>");
            out.println("<p>Branch ID: " + branchId + "</p>");
            
            // Check if item exists
            String checkSql = "SELECT id FROM checklist_items WHERE item_name = ?";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setString(1, itemName);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (!checkRs.next()) {
                out.println("<p style='color: blue;'>Item does not exist, creating new item...</p>");
                checkRs.close();
                checkPs.close();
                
                // Try different approaches to get the ID
                out.println("<h3>Method 1: RETURN_GENERATED_KEYS</h3>");
                try {
                    String insertSql = "INSERT INTO checklist_items (item_name) VALUES (?)";
                    PreparedStatement insertPs = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                    insertPs.setString(1, itemName);
                    int result = insertPs.executeUpdate();
                    
                    ResultSet generatedKeys = insertPs.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        int newId = generatedKeys.getInt(1);
                        out.println("<p style='color: green;'>✓ Method 1 successful! New ID: " + newId + "</p>");
                    } else {
                        out.println("<p style='color: red;'>✗ Method 1 failed - no generated keys returned</p>");
                    }
                    generatedKeys.close();
                    insertPs.close();
                } catch (Exception e) {
                    out.println("<p style='color: red;'>✗ Method 1 failed: " + e.getMessage() + "</p>");
                }
                
                out.println("<h3>Method 2: CURRVAL approach</h3>");
                try {
                    String insertSql = "INSERT INTO checklist_items (item_name) VALUES (?)";
                    PreparedStatement insertPs = con.prepareStatement(insertSql);
                    insertPs.setString(1, itemName + "_v2");
                    int result = insertPs.executeUpdate();
                    insertPs.close();
                    
                    // Get the last inserted ID
                    String getIdSql = "SELECT currval('checklist_items_id_seq')";
                    PreparedStatement getIdPs = con.prepareStatement(getIdSql);
                    ResultSet getIdRs = getIdPs.executeQuery();
                    
                    if (getIdRs.next()) {
                        int newId = getIdRs.getInt(1);
                        out.println("<p style='color: green;'>✓ Method 2 successful! New ID: " + newId + "</p>");
                    } else {
                        out.println("<p style='color: red;'>✗ Method 2 failed - no ID returned</p>");
                    }
                    getIdRs.close();
                    getIdPs.close();
                } catch (Exception e) {
                    out.println("<p style='color: red;'>✗ Method 2 failed: " + e.getMessage() + "</p>");
                }
                
            } else {
                int existingId = checkRs.getInt("id");
                out.println("<p style='color: orange;'>Item already exists with ID: " + existingId + "</p>");
                checkRs.close();
                checkPs.close();
            }
            
            // Show table structure
            out.println("<h3>Table Structure</h3>");
            String structSql = "SELECT column_name, data_type, column_default FROM information_schema.columns WHERE table_name = 'checklist_items' ORDER BY ordinal_position";
            PreparedStatement structPs = con.prepareStatement(structSql);
            ResultSet structRs = structPs.executeQuery();
            
            out.println("<table border='1' cellpadding='5'>");
            out.println("<tr><th>Column</th><th>Type</th><th>Default</th></tr>");
            while (structRs.next()) {
                out.println("<tr>");
                out.println("<td>" + structRs.getString("column_name") + "</td>");
                out.println("<td>" + structRs.getString("data_type") + "</td>");
                out.println("<td>" + structRs.getString("column_default") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            
            structRs.close();
            structPs.close();
            con.close();
            
            out.println("<p><a href='admin.jsp'>Return to Admin Dashboard</a></p>");
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<h2 style='color: red;'>Debug Error</h2>");
            out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
            out.println("<p><a href='admin.jsp'>Return to Admin Dashboard</a></p>");
        }
    }
}

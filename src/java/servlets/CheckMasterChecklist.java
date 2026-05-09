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
import config.DatabaseConfig;

@WebServlet("/CheckMasterChecklist")
public class CheckMasterChecklist extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            // Check if master checklist items exist
            String checkSql = "SELECT COUNT(*) as count FROM checklist_items";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (checkRs.next()) {
                int count = checkRs.getInt("count");
                out.println("<h2>Master Checklist Items</h2>");
                out.println("<p>Total items in master checklist: " + count + "</p>");
                
                if (count == 0) {
                    out.println("<p style='color: red;'>No items found in master checklist!</p>");
                    out.println("<p>You need to add items to the master checklist first before assigning them to branches.</p>");
                    
                    // Add some sample items
                    String insertSql = "INSERT INTO checklist_items (item_name) VALUES (?)";
                    PreparedStatement insertPs = con.prepareStatement(insertSql);
                    
                    String[] sampleItems = {
                        "Check entry points",
                        "Verify security cameras",
                        "Review access logs",
                        "Check alarm systems",
                        "Inspect perimeter fencing"
                    };
                    
                    for (String item : sampleItems) {
                        insertPs.setString(1, item);
                        insertPs.executeUpdate();
                    }
                    
                    insertPs.close();
                    out.println("<p style='color: green;'>Added 5 sample checklist items to master checklist.</p>");
                } else {
                    // Show existing items
                    String listSql = "SELECT id, item_name FROM checklist_items ORDER BY item_name";
                    PreparedStatement listPs = con.prepareStatement(listSql);
                    ResultSet listRs = listPs.executeQuery();
                    
                    out.println("<h3>Available Checklist Items:</h3>");
                    out.println("<ul>");
                    while (listRs.next()) {
                        out.println("<li>" + listRs.getString("item_name") + " (ID: " + listRs.getInt("id") + ")</li>");
                    }
                    out.println("</ul>");
                    
                    listRs.close();
                    listPs.close();
                }
            }
            
            checkRs.close();
            checkPs.close();
            con.close();
            
            out.println("<p><a href='admin.jsp'>Return to Admin Dashboard</a></p>");
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<h2 style='color: red;'>Error Checking Master Checklist</h2>");
            out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
            out.println("<p><a href='admin.jsp'>Return to Admin Dashboard</a></p>");
        }
    }
}

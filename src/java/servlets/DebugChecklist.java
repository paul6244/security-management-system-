package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;
import config.DatabaseConfig;

@WebServlet("/DebugChecklist")
public class DebugChecklist extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<h1>Debug Checklist Database</h1>");
        
        Connection con = null;
        try {
            con = DatabaseConfig.getConnection();
            out.println("<p style='color: green;'>✓ Database connection successful</p>");
            
            // Check if checklist_items table exists
            try {
                PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM checklist_items");
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("<p>✓ checklist_items table exists with " + count + " items</p>");
                    
                    // Show all items
                    rs.close();
                    ps.close();
                    ps = con.prepareStatement("SELECT * FROM checklist_items ORDER BY id");
                    rs = ps.executeQuery();
                    out.println("<table border='1'><tr><th>ID</th><th>Item Name</th></tr>");
                    while (rs.next()) {
                        out.println("<tr><td>" + rs.getInt("id") + "</td><td>" + rs.getString("item_name") + "</td></tr>");
                    }
                    out.println("</table>");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                out.println("<p style='color: red;'>✗ Error checking checklist_items: " + e.getMessage() + "</p>");
            }
            
            // Check if branch_checklist_items table exists
            try {
                PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM branch_checklist_items");
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("<p>✓ branch_checklist_items table exists with " + count + " items</p>");
                    
                    // Show all items
                    rs.close();
                    ps.close();
                    ps = con.prepareStatement("SELECT bci.*, ci.item_name, br.name as branch_name FROM branch_checklist_items bci JOIN checklist_items ci ON bci.item_id = ci.id JOIN branches br ON bci.branch_id = br.id ORDER BY bci.id");
                    rs = ps.executeQuery();
                    out.println("<table border='1'><tr><th>ID</th><th>Branch</th><th>Item</th></tr>");
                    while (rs.next()) {
                        out.println("<tr><td>" + rs.getInt("id") + "</td><td>" + rs.getString("branch_name") + "</td><td>" + rs.getString("item_name") + "</td></tr>");
                    }
                    out.println("</table>");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                out.println("<p style='color: red;'>✗ Error checking branch_checklist_items: " + e.getMessage() + "</p>");
            }
            
            // Test adding a new item
            out.println("<h2>Test Adding New Item</h2>");
            try {
                // Check if "TestItem" exists
                PreparedStatement ps = con.prepareStatement("SELECT id FROM checklist_items WHERE item_name = ?");
                ps.setString(1, "TestItem");
                ResultSet rs = ps.executeQuery();
                
                if (!rs.next()) {
                    // Create the item
                    rs.close();
                    ps.close();
                    
                    String insertSql = "INSERT INTO checklist_items (item_name) VALUES (?)";
                    PreparedStatement insertPs = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                    insertPs.setString(1, "TestItem");
                    insertPs.executeUpdate();
                    
                    ResultSet generatedKeys = insertPs.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        int newId = generatedKeys.getInt(1);
                        out.println("<p style='color: green;'>✓ Successfully created TestItem with ID: " + newId + "</p>");
                    }
                    generatedKeys.close();
                    insertPs.close();
                } else {
                    out.println("<p style='color: blue;'>TestItem already exists with ID: " + rs.getInt("id") + "</p>");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                out.println("<p style='color: red;'>✗ Error testing item creation: " + e.getMessage() + "</p>");
                e.printStackTrace(out);
            }
            
        } catch (Exception e) {
            out.println("<p style='color: red;'>✗ Database connection failed: " + e.getMessage() + "</p>");
            e.printStackTrace(out);
        } finally {
            try {
                if (con != null && !con.isClosed()) {
                    con.close();
                }
            } catch (Exception e) {
                // Ignore close errors
            }
        }
        
        out.println("<p><a href='admin.jsp'>Return to Admin Dashboard</a></p>");
    }
}

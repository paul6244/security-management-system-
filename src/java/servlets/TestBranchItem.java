package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;
import config.DatabaseConfig;

@WebServlet("/TestBranchItem")
public class TestBranchItem extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<h1>Test Branch Item Link</h1>");
        
        Connection con = null;
        try {
            con = DatabaseConfig.getConnection();
            out.println("<p style='color: green;'>✓ Database connection successful</p>");
            
            // Get branches
            PreparedStatement ps = con.prepareStatement("SELECT id, name FROM branches ORDER BY id");
            ResultSet rs = ps.executeQuery();
            out.println("<h2>Available Branches:</h2>");
            while (rs.next()) {
                out.println("<p>Branch ID: " + rs.getInt("id") + " - Name: " + rs.getString("name") + "</p>");
            }
            rs.close();
            ps.close();
            
            // Test adding item to branch 1 (assuming it exists)
            out.println("<h2>Test Adding Item to Branch 1:</h2>");
            
            // First create a test item
            String insertItemSql = "INSERT INTO checklist_items (item_name) VALUES (?) RETURNING id";
            PreparedStatement insertItemPs = con.prepareStatement(insertItemSql);
            insertItemPs.setString(1, "TestBranchItem");
            ResultSet itemRs = insertItemPs.executeQuery();
            int itemId = 0;
            if (itemRs.next()) {
                itemId = itemRs.getInt(1);
                out.println("<p style='color: green;'>✓ Created test item with ID: " + itemId + "</p>");
            }
            itemRs.close();
            insertItemPs.close();
            
            // Now add to branch
            if (itemId > 0) {
                String insertBranchSql = "INSERT INTO branch_checklist_items (branch_id, item_id) VALUES (?, ?)";
                PreparedStatement insertBranchPs = con.prepareStatement(insertBranchSql);
                insertBranchPs.setInt(1, 1); // Branch ID 1
                insertBranchPs.setInt(2, itemId);
                int result = insertBranchPs.executeUpdate();
                insertBranchPs.close();
                
                if (result > 0) {
                    out.println("<p style='color: green;'>✓ Successfully added item to branch!</p>");
                } else {
                    out.println("<p style='color: red;'>✗ Failed to add item to branch</p>");
                }
                
                // Verify it was added
                PreparedStatement checkPs = con.prepareStatement("SELECT COUNT(*) FROM branch_checklist_items WHERE branch_id = ? AND item_id = ?");
                checkPs.setInt(1, 1);
                checkPs.setInt(2, itemId);
                ResultSet checkRs = checkPs.executeQuery();
                if (checkRs.next()) {
                    out.println("<p style='color: green;'>✓ Verification: Item found in branch_checklist_items</p>");
                } else {
                    out.println("<p style='color: red;'>✗ Verification: Item NOT found in branch_checklist_items</p>");
                }
                checkRs.close();
                checkPs.close();
            }
            
        } catch (Exception e) {
            out.println("<p style='color: red;'>✗ Error: " + e.getMessage() + "</p>");
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

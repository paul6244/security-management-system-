package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import config.DatabaseConfig;

@WebServlet("/CreateDatabaseTables")
public class CreateDatabaseTables extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            Connection con = DatabaseConfig.getConnection();
            Statement stmt = con.createStatement();
            
            // Create branch_checklist_items table if it doesn't exist
            String createTableSQL = "CREATE TABLE IF NOT EXISTS branch_checklist_items (" +
                    "id SERIAL PRIMARY KEY, " +
                    "branch_id INT NOT NULL, " +
                    "item_id INT NOT NULL, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE, " +
                    "FOREIGN KEY (item_id) REFERENCES checklist_items(id) ON DELETE CASCADE, " +
                    "UNIQUE (branch_id, item_id)" +
                    ")";
            
            stmt.executeUpdate(createTableSQL);
            
            out.println("<h2>Database Tables Created Successfully</h2>");
            out.println("<p>The branch_checklist_items table has been created.</p>");
            out.println("<p><a href='admin.jsp'>Return to Admin Dashboard</a></p>");
            
            stmt.close();
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<h2 style='color: red;'>Error Creating Database Tables</h2>");
            out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
            out.println("<p><a href='admin.jsp'>Return to Admin Dashboard</a></p>");
        }
    }
}

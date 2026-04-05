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
import config.SimpleDatabaseConfig;

@WebServlet("/DatabaseMigration")
public class DatabaseMigration extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Connection con = null;
        Statement stmt = null;
        
        try {
            con = SimpleDatabaseConfig.getSimpleConnection();
            stmt = con.createStatement();
            
            // Check if fingerprint_data column exists
            boolean columnExists = false;
            try {
                stmt.executeQuery("SELECT fingerprint_data FROM staff_registration LIMIT 1");
                columnExists = true;
            } catch (Exception e) {
                // Column doesn't exist
                columnExists = false;
            }
            
            if (!columnExists) {
                // Add fingerprint_data column
                String alterSql = "ALTER TABLE staff_registration ADD COLUMN fingerprint_data TEXT";
                stmt.executeUpdate(alterSql);
                
                out.println("<html><body>");
                out.println("<h2>Database Migration Successful</h2>");
                out.println("<p>Successfully added fingerprint_data column to staff_registration table.</p>");
                out.println("<p><a href='staffRegistration.jsp'>Go to Staff Registration</a></p>");
                out.println("</body></html>");
            } else {
                out.println("<html><body>");
                out.println("<h2>Database Already Up-to-Date</h2>");
                out.println("<p>The fingerprint_data column already exists in staff_registration table.</p>");
                out.println("<p><a href='staffRegistration.jsp'>Go to Staff Registration</a></p>");
                out.println("</body></html>");
            }
            
        } catch (Exception e) {
            out.println("<html><body>");
            out.println("<h2>Database Migration Failed</h2>");
            out.println("<p>Error: " + e.getMessage() + "</p>");
            out.println("<p>Please check database connection and permissions.</p>");
            out.println("</body></html>");
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (Exception e) {
                // Log error if needed
            }
        }
    }
}

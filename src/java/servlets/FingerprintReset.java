package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import config.SimpleDatabaseConfig;

@WebServlet("/FingerprintReset")
public class FingerprintReset extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            con = SimpleDatabaseConfig.getSimpleConnection();
            stmt = con.createStatement();
            
            out.println("<html><body>");
            out.println("<h2>Fingerprint Database Reset</h2>");
            
            // Step 1: Clear any existing fingerprint data
            try {
                // Check if fingerprint_data column exists
                boolean columnExists = false;
                try {
                    rs = stmt.executeQuery("SELECT fingerprint_data FROM staff_registration LIMIT 1");
                    columnExists = true;
                    rs.close();
                } catch (Exception e) {
                    columnExists = false;
                }
                
                if (columnExists) {
                    // Clear existing fingerprint data
                    int clearedRows = stmt.executeUpdate("UPDATE staff_registration SET fingerprint_data = NULL");
                    out.println("<p>✅ Cleared fingerprint data from " + clearedRows + " staff records.</p>");
                } else {
                    out.println("<p>ℹ️ No fingerprint_data column found yet.</p>");
                }
                
            } catch (Exception e) {
                out.println("<p>⚠️ Error clearing fingerprint data: " + e.getMessage() + "</p>");
            }
            
            // Step 2: Add fingerprint_data column if it doesn't exist
            try {
                boolean columnExists = false;
                try {
                    rs = stmt.executeQuery("SELECT fingerprint_data FROM staff_registration LIMIT 1");
                    columnExists = true;
                    rs.close();
                } catch (Exception e) {
                    columnExists = false;
                }
                
                if (!columnExists) {
                    // Add fingerprint_data column
                    String alterSql = "ALTER TABLE staff_registration ADD COLUMN fingerprint_data TEXT";
                    stmt.executeUpdate(alterSql);
                    out.println("<p>✅ Added fingerprint_data column to staff_registration table.</p>");
                } else {
                    out.println("<p>✅ fingerprint_data column already exists.</p>");
                }
                
            } catch (Exception e) {
                out.println("<p>❌ Error adding fingerprint_data column: " + e.getMessage() + "</p>");
            }
            
            // Step 3: Show current status
            try {
                rs = stmt.executeQuery("SELECT COUNT(*) as total, COUNT(fingerprint_data) as with_fp FROM staff_registration");
                if (rs.next()) {
                    int total = rs.getInt("total");
                    int withFp = rs.getInt("with_fp");
                    out.println("<p>📊 Database Status:</p>");
                    out.println("<ul>");
                    out.println("<li>Total staff records: " + total + "</li>");
                    out.println("<li>With fingerprint data: " + withFp + "</li>");
                    out.println("<li>Ready for fingerprint registration: " + (total - withFp) + "</li>");
                    out.println("</ul>");
                }
                rs.close();
            } catch (Exception e) {
                out.println("<p>⚠️ Error checking status: " + e.getMessage() + "</p>");
            }
            
            out.println("<p><a href='staffRegistration.jsp'>Go to Staff Registration</a></p>");
            out.println("<p><a href='index.jsp'>Go to Login</a></p>");
            out.println("</body></html>");
            
        } catch (Exception e) {
            out.println("<html><body>");
            out.println("<h2>Fingerprint Reset Failed</h2>");
            out.println("<p>Error: " + e.getMessage() + "</p>");
            out.println("<p>Please check database connection and permissions.</p>");
            out.println("<p><a href='index.jsp'>Return to Login</a></p>");
            out.println("</body></html>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (Exception e) {
                // Log error if needed
            }
        }
    }
}

package servlets;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import config.SimpleDatabaseConfig;

@WebServlet("/SystemDiagnostics")
public class SystemDiagnostics extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            Connection con = SimpleDatabaseConfig.getSimpleConnection();
            DatabaseMetaData meta = con.getMetaData();
            
            StringBuilder diagnostics = new StringBuilder();
            diagnostics.append("{");
            diagnostics.append("\"database_connection\": \"");
            diagnostics.append(con != null && !con.isClosed() ? "SUCCESS" : "FAILED");
            diagnostics.append("\",");
            
            // Check database info
            diagnostics.append("\"database_url\": \"");
            try {
                diagnostics.append(con.getMetaData().getURL());
            } catch (Exception e) {
                diagnostics.append("Unknown");
            }
            diagnostics.append("\",");
            
            // Check tables
            diagnostics.append("\"tables\": {");
            
            String[] requiredTables = {"users", "staff_registration", "attendance", "shifts"};
            
            for (String table : requiredTables) {
                diagnostics.append("\"").append(table).append("\": {");
                diagnostics.append("\"exists\": \"");
                
                try {
                    ResultSet tables = meta.getTables(null, null, table, new String[]{"TABLE"});
                    boolean exists = tables.next();
                    diagnostics.append(exists ? "YES" : "NO");
                    diagnostics.append("\",");
                    
                    if (exists) {
                        diagnostics.append("\"record_count\": \"");
                        try {
                            Connection countCon = SimpleDatabaseConfig.getSimpleConnection();
                            String countSql = "SELECT COUNT(*) FROM " + table;
                            java.sql.PreparedStatement countStmt = countCon.prepareStatement(countSql);
                            ResultSet countRs = countStmt.executeQuery();
                            if (countRs.next()) {
                                diagnostics.append(countRs.getString(1));
                            }
                            countRs.close();
                            countStmt.close();
                            countCon.close();
                        } catch (Exception e) {
                            diagnostics.append("0");
                        }
                    } else {
                        diagnostics.append("\"record_count\": \"0\"");
                    }
                    diagnostics.append("},");
                    
                    tables.close();
                } catch (SQLException e) {
                    diagnostics.append("\"exists\": \"NO\", \"error\": \"").append(e.getMessage()).append("\"},");
                }
            }
            
            diagnostics.append("},");
            diagnostics.append("\"system_info\": {");
            diagnostics.append("\"java_version\": \"").append(System.getProperty("java.version")).append("\",");
            diagnostics.append("\"available_memory\": \"").append(Runtime.getRuntime().freeMemory() / 1024 / 1024).append(" MB\",");
            diagnostics.append("\"server_time\": \"").append(new java.util.Date()).append("\",");
            diagnostics.append("\"deployment\": \"HEROKU\"");
            diagnostics.append("},");
            diagnostics.append("\"recommendations\": [");
            
            // Add recommendations based on diagnostics
            if (con == null || con.isClosed()) {
                diagnostics.append("\"Check DATABASE_URL environment variable\",");
                diagnostics.append("\"Verify PostgreSQL driver is available\",");
                diagnostics.append("\"Ensure database is accessible\"");
            } else {
                diagnostics.append("\"Database connection working\",");
                diagnostics.append("\"Test staff registration functionality\",");
                diagnostics.append("\"Verify attendance submission process\"");
            }
            
            diagnostics.append("]}");
            
            response.getWriter().write(diagnostics.toString());
            
        } catch (Exception e) {
            String errorResponse = "{";
            errorResponse += "\"success\": false,";
            errorResponse += "\"message\": \"System diagnostics failed: " + e.getMessage().replace("\"", "\\\"") + "\",";
            errorResponse += "\"error_type\": \"";
            errorResponse += e.getClass().getSimpleName();
            errorResponse += "\"}";
            
            response.getWriter().write(errorResponse);
        }
    }
}

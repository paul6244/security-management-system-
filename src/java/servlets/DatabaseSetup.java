package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import config.SimpleDatabaseConfig;

@WebServlet("/DatabaseSetup")
public class DatabaseSetup extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Database Setup & Diagnostics</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println("table { border-collapse: collapse; width: 100%; margin: 20px 0; }");
        out.println("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        out.println("th { background-color: #f2f2f2; }");
        out.println(".success { color: green; font-weight: bold; }");
        out.println(".error { color: red; font-weight: bold; }");
        out.println(".info { color: blue; }");
        out.println(".btn { background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 5px; display: inline-block; }");
        out.println(".btn:hover { background: #0056b3; }");
        out.println("</style></head><body>");
        
        out.println("<h2>Database Setup & Diagnostics</h2>");
        
        Connection conn = null;
        try {
            out.println("<h3>1. Testing Simple Database Connection</h3>");
            conn = SimpleDatabaseConfig.getSimpleConnection();
            
            if (conn != null) {
                out.println("<p class='success'>✅ Database connection established!</p>");
                out.println("<p>Connection valid: " + conn.isValid(5) + "</p>");
                out.println("<p>Database: " + conn.getMetaData().getDatabaseProductName() + "</p>");
                
                // Check existing tables
                out.println("<h3>2. Checking Existing Tables</h3>");
                DatabaseMetaData metaData = conn.getMetaData();
                ResultSet tables = metaData.getTables(null, null, "%", new String[]{"TABLE"});
                
                out.println("<table>");
                out.println("<tr><th>Table Name</th><th>Exists</th><th>Action</th></tr>");
                
                String[] requiredTables = {
                    "users", "security_personnel", "staff_registration", 
                    "attendance", "shifts", "shift_checks", "branches"
                };
                
                // Check required tables
                for (String tableName : requiredTables) {
                    boolean tableExists = false;
                    tables.beforeFirst();
                    while (tables.next()) {
                        if (tableName.equalsIgnoreCase(tables.getString("TABLE_NAME"))) {
                            tableExists = true;
                            break;
                        }
                    }
                    
                    out.println("<tr>");
                    out.println("<td>" + tableName + "</td>");
                    out.println("<td class='" + (tableExists ? "success" : "error") + "'>" + (tableExists ? "✅ EXISTS" : "❌ MISSING") + "</td>");
                    out.println("<td>");
                    if (!tableExists) {
                        out.println("<a href='?action=create&table=" + tableName + "' class='btn'>Create Table</a>");
                    } else {
                        out.println("<a href='?action=check&table=" + tableName + "' class='btn'>Check Data</a>");
                    }
                    out.println("</td>");
                    out.println("</tr>");
                }
                
                out.println("</table>");
                
                // Handle table creation/data checking
                String action = request.getParameter("action");
                String table = request.getParameter("table");
                
                if (action != null && table != null) {
                    Statement stmt = conn.createStatement();
                    
                    if (action.equals("create")) {
                        out.println("<h3>Creating Table: " + table + "</h3>");
                        try {
                            if (table.equals("users")) {
                                stmt.executeUpdate("CREATE TABLE users (id SERIAL PRIMARY KEY, username VARCHAR(50) UNIQUE, password VARCHAR(255), role VARCHAR(20), email VARCHAR(100))");
                                out.println("<p class='success'>✅ Users table created</p>");
                            } else if (table.equals("staff_registration")) {
                                stmt.executeUpdate("CREATE TABLE staff_registration (id SERIAL PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50), email VARCHAR(100) UNIQUE, phone VARCHAR(20), department VARCHAR(50), position VARCHAR(50), employee_id VARCHAR(20) UNIQUE, office_location VARCHAR(100), address TEXT, selfie_path VARCHAR(255))");
                                out.println("<p class='success'>✅ Staff registration table created</p>");
                            } else if (table.equals("attendance")) {
                                stmt.executeUpdate("CREATE TABLE attendance (id SERIAL PRIMARY KEY, staff_id INTEGER, employee_id VARCHAR(20), first_name VARCHAR(50), last_name VARCHAR(50), check_in_time TIMESTAMP, face_verified BOOLEAN, selfie_path VARCHAR(255))");
                                out.println("<p class='success'>✅ Attendance table created</p>");
                            } else if (table.equals("shifts")) {
                                stmt.executeUpdate("CREATE TABLE shifts (id SERIAL PRIMARY KEY, user_id INTEGER, start_time TIMESTAMP, end_time TIMESTAMP, status VARCHAR(20))");
                                out.println("<p class='success'>✅ Shifts table created</p>");
                            } else if (table.equals("shift_checks")) {
                                stmt.executeUpdate("CREATE TABLE shift_checks (id SERIAL PRIMARY KEY, personnel_id INTEGER, item_id INTEGER, status VARCHAR(20), check_time TIMESTAMP, notes TEXT)");
                                out.println("<p class='success'>✅ Shift checks table created</p>");
                            } else if (table.equals("branches")) {
                                stmt.executeUpdate("CREATE TABLE branches (id SERIAL PRIMARY KEY, name VARCHAR(100) UNIQUE, location VARCHAR(255), manager VARCHAR(100))");
                                out.println("<p class='success'>✅ Branches table created</p>");
                            } else if (table.equals("security_personnel")) {
                                stmt.executeUpdate("CREATE TABLE security_personnel (id SERIAL PRIMARY KEY, name VARCHAR(100), email VARCHAR(100) UNIQUE, branch_id INTEGER, shift_time VARCHAR(50), user_id INTEGER)");
                                out.println("<p class='success'>✅ Security personnel table created</p>");
                            }
                        } catch (Exception e) {
                            out.println("<p class='error'>❌ Error creating table: " + e.getMessage() + "</p>");
                        }
                    } else if (action.equals("check")) {
                        out.println("<h3>Checking Data in: " + table + "</h3>");
                        try {
                            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM " + table);
                            if (rs.next()) {
                                int count = rs.getInt("count");
                                out.println("<p class='info'>ℹ️ Records in " + table + ": " + count + "</p>");
                            }
                            rs.close();
                        } catch (Exception e) {
                            out.println("<p class='error'>❌ Error checking data: " + e.getMessage() + "</p>");
                        }
                    }
                    
                    stmt.close();
                }
                
                tables.close();
                
            } else {
                out.println("<p class='error'>❌ Failed to establish database connection</p>");
            }
            
        } catch (Exception e) {
            out.println("<p class='error'>❌ DATABASE ERROR: " + e.getMessage() + "</p>");
            out.println("<h3>Error Details:</h3>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    out.println("<p class='info'>ℹ️ Database connection closed</p>");
                } catch (Exception e) {
                    out.println("<p class='error'>❌ Error closing connection: " + e.getMessage() + "</p>");
                }
            }
        }
        
        out.println("<br><br>");
        out.println("<h3>3. Navigation</h3>");
        out.println("<a href='AttendanceDatabaseCheck' class='btn'>← Attendance Database Check</a><br>");
        out.println("<a href='DirectConnectionTest' class='btn'>← Direct Connection Test</a><br>");
        out.println("<a href='SimpleConnectionTest' class='btn'>← Simple Connection Test</a><br>");
        out.println("<a href='EnvCheck' class='btn'>← Environment Check</a><br>");
        out.println("<a href='attendance.jsp' class='btn'>← Go to Attendance Page</a><br>");
        out.println("<a href='index.jsp' class='btn'>← Back to Login</a>");
        out.println("</body></html>");
    }
}

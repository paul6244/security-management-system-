package servlets;

import java.io.File;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CreateSelfieFolder")
public class CreateSelfieFolder extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // For Heroku deployment, use temporary directory
            String selfieDirPath = System.getProperty("java.io.tmpdir") + File.separator + "attendance_selfies";
            
            File selfieDir = new File(selfieDirPath);
            
            boolean created = false;
            String message = "";
            
            if (!selfieDir.exists()) {
                created = selfieDir.mkdirs();
                if (created) {
                    message = "Selfie folder created successfully at: " + selfieDirPath;
                } else {
                    message = "Failed to create selfie folder at: " + selfieDirPath;
                }
            } else {
                message = "Selfie folder already exists at: " + selfieDirPath;
                created = true; // Already exists
            }
            
            // Test write permissions
            File testFile = new File(selfieDir, "test.txt");
            try {
                if (testFile.createNewFile()) {
                    testFile.delete();
                    message += " | Write permissions: OK";
                } else {
                    message += " | Write permissions: FAILED";
                }
            } catch (Exception e) {
                message += " | Write permissions: ERROR - " + e.getMessage();
            }
            
            // Return JSON response
            String jsonResponse = "{";
            jsonResponse += "\"success\": " + created + ",";
            jsonResponse += "\"message\": \"" + message.replace("\"", "\\\"") + "\",";
            jsonResponse += "\"path\": \"" + selfieDirPath.replace("\\", "\\\\") + "\"";
            jsonResponse += "}";
            
            response.getWriter().write(jsonResponse);
            
        } catch (Exception e) {
            String errorResponse = "{";
            errorResponse += "\"success\": false,";
            errorResponse += "\"message\": \"Error creating selfie folder: " + e.getMessage().replace("\"", "\\\"") + "\"";
            errorResponse += "}";
            
            response.getWriter().write(errorResponse);
        }
    }
}

package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/VerifyCode")
public class VerifyCode extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String enteredCode = request.getParameter("verificationCode");
        String sessionCode = (String) request.getSession().getAttribute("verificationCode");
        String verifiedEmployeeId = (String) request.getSession().getAttribute("verifiedEmployeeId");
        String action = (String) request.getSession().getAttribute("verificationAction");
        
        if (enteredCode == null || enteredCode.trim().isEmpty()) {
            out.println("{\"success\": false, \"message\": \"Please enter verification code\"}");
            return;
        }
        
        if (sessionCode == null) {
            out.println("{\"success\": false, \"message\": \"No verification code found. Please request a new code.\"}");
            return;
        }
        
        if (enteredCode.equals(sessionCode)) {
            // Clear verification code from session
            request.getSession().removeAttribute("verificationCode");
            
            // Mark as verified for this session
            request.getSession().setAttribute("verifiedFor" + action, verifiedEmployeeId);
            
            out.println("{\"success\": true, \"message\": \"Verification successful! You can now proceed with " + action + "\", \"employeeId\": \"" + verifiedEmployeeId + "\"}");
        } else {
            out.println("{\"success\": false, \"message\": \"Invalid verification code. Please try again.\"}");
        }
    }
}

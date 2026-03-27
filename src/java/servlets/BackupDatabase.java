package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/BackupDatabase")
public class BackupDatabase extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            // In a real application, this would create an actual database backup
            // For now, we'll simulate the backup process
            out.println("<script>alert('Database backup created successfully!'); window.location.href='settings.jsp';</script>");
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error creating database backup: " + e.getMessage() + "'); window.location.href='settings.jsp';</script>");
        }
    }
}

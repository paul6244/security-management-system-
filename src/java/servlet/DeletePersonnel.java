package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.Mymodel;

@WebServlet("/DeletePersonnel")
public class DeletePersonnel extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String personnelIdStr = request.getParameter("personnelId");
        
        if (personnelIdStr == null || personnelIdStr.trim().isEmpty()) {
            response.sendRedirect("admin.jsp?error=missing_personnel_id");
            return;
        }
        
        try {
            int personnelId = Integer.parseInt(personnelIdStr);
            boolean success = Mymodel.deletePersonnel(personnelId);
            
            if (success) {
                response.sendRedirect("admin.jsp?status=success&message=Personnel deleted successfully");
            } else {
                response.sendRedirect("admin.jsp?error=delete_failed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("admin.jsp?error=invalid_personnel_id");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?error=system_error");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}

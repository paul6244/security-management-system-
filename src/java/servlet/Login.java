package servlet;

import java.io.IOException;
import model.Mymodel;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/Login")
public class Login extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        HttpSession session = request.getSession();

        // Validate empty fields
        if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
            session.setAttribute("loginError", "All fields are required.");
            response.sendRedirect("index.jsp");
            return;
        }

        // Get user role
        String role = Mymodel.getUserRole(username, password);

        if (role != null) {

            session.setAttribute("username", username);
            session.setAttribute("role", role);

            if (role.equals("admin")) {
                response.sendRedirect("admin.jsp");
            } 
            else if (role.equals("security_officer")) {
                response.sendRedirect("personnelDashboard.jsp");
            }

        } else {

            session.setAttribute("loginError", "Invalid username or password");
            response.sendRedirect("index.jsp");

        }
        
        

    } // This method handles both GET and POST requests for login processing
    } // ✅ This method handles both GET and POST requests for login processing
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);

    }

    @Override
    public String getServletInfo() {
        return "Login Servlet";
    }
}
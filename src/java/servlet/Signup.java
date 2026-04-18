package servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.Mymodel;

@WebServlet("/Signup")
public class Signup extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        String branch_id = request.getParameter("branch_id");
        String shift_time = request.getParameter("shift_time");

        HttpSession session = request.getSession();

        // Basic validation
        if(username == null || username.isEmpty() || email == null || email.isEmpty() || password == null || password.isEmpty() || role == null || role.isEmpty()){
            session.setAttribute("signupError", "All required fields must be filled.");
            response.sendRedirect("Signup.jsp");
            return;
        }
        
        // Validate password confirmation
        String confirmPassword = request.getParameter("confirmPassword");
        if(!password.equals(confirmPassword)){
            session.setAttribute("signupError", "Passwords do not match.");
            response.sendRedirect("Signup.jsp");
            return;
        }

        // For Security Officer, branch and shift must be provided
        if(role.equals("security_officer") && (branch_id == null || branch_id.isEmpty() || shift_time == null || shift_time.isEmpty())){
            session.setAttribute("signupError", "Branch and Shift Time are required for Security Officers.");
            response.sendRedirect("Signup.jsp");
            return;
        }

        // Check if username exists
        if(Mymodel.userExists(username)){
            session.setAttribute("signupError", "Username already exists.");
            response.sendRedirect("Signup.jsp");
            return;
        }

        // Check if email exists
        if(Mymodel.emailExists(email)){
            session.setAttribute("signupError", "Email already exists.");
            response.sendRedirect("Signup.jsp");
            return;
        }

        // Save user
        boolean saved = Mymodel.saveUserWithRole(
                username, email, password, role,
                branch_id, shift_time
        );

        if(saved){
            session.setAttribute("signupSuccess", "Account created successfully.");
            response.sendRedirect("index.jsp");
        } else {
            session.setAttribute("signupError", "Something went wrong while saving the account.");
            response.sendRedirect("Signup.jsp");
        }
    }
}

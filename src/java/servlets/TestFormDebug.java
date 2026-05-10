package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;

@WebServlet("/TestFormDebug")
public class TestFormDebug extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<h1>Form Debug Test</h1>");
        out.println("<p>This page tests if JavaScript form submission works.</p>");
        
        out.println("<form id='testForm'>");
        out.println("  <input type='text' id='testInput' placeholder='Enter test value'>");
        out.println("  <button type='submit'>Test Submit</button>");
        out.println("</form>");
        
        out.println("<div id='result'></div>");
        
        out.println("<script>");
        out.println("  console.log('Debug script loaded');");
        out.println("  ");
        out.println("  document.getElementById('testForm').addEventListener('submit', function(e) {");
        out.println("    e.preventDefault();");
        out.println("    console.log('Test form submitted!');");
        out.println("    const value = document.getElementById('testInput').value;");
        out.println("    console.log('Input value:', value);");
        out.println("    document.getElementById('result').innerHTML = 'Form submitted with value: ' + value;");
        out.println("  });");
        out.println("  ");
        out.println("  console.log('Event listener attached');");
        out.println("</script>");
        
        out.println("<p><a href='admin.jsp'>Return to Admin Dashboard</a></p>");
    }
}

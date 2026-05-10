package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;

@WebServlet("/AdminTest")
public class AdminTest extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Admin Dashboard Test</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println("button { padding: 10px 20px; margin: 10px; background: #007bff; color: white; border: none; cursor: pointer; }");
        out.println("button:hover { background: #0056b3; }");
        out.println(".form-section { border: 1px solid #ccc; padding: 20px; margin: 20px 0; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        
        out.println("<h1>🔧 Admin Dashboard Test</h1>");
        out.println("<p>This page tests the admin dashboard functionality without complex dependencies.</p>");
        
        // Test basic JavaScript
        out.println("<div class='form-section'>");
        out.println("<h3>Test 1: Basic JavaScript</h3>");
        out.println("<button onclick='alert(\"JavaScript works!\")'>Test JavaScript</button>");
        out.println("</div>");
        
        // Test form submission
        out.println("<div class='form-section'>");
        out.println("<h3>Test 2: Form Submission</h3>");
        out.println("<form id='testForm'>");
        out.println("  <input type='text' id='testInput' placeholder='Enter test value'>");
        out.println("  <button type='submit'>Submit Form</button>");
        out.println("</form>");
        out.println("<div id='formResult'></div>");
        out.println("</div>");
        
        // Test checklist functionality
        out.println("<div class='form-section'>");
        out.println("<h3>Test 3: Checklist Functionality</h3>");
        out.println("<button id='showAddForm'>Show Add Form</button>");
        out.println("<div id='addForm' style='display: none; margin-top: 10px;'>");
        out.println("  <form id='checklistForm'>");
        out.println("    <input type='text' id='itemName' placeholder='Item name' required><br><br>");
        out.println("    <select id='itemBranch' required>");
        out.println("      <option value=''>Select Branch</option>");
        out.println("      <option value='28'>Accra</option>");
        out.println("      <option value='37'>Techiman</option>");
        out.println("    </select><br><br>");
        out.println("    <button type='submit'>Add Item</button>");
        out.println("    <button type='button' onclick='hideForm()'>Cancel</button>");
        out.println("  </form>");
        out.println("</div>");
        out.println("<div id='checklistResult'></div>");
        out.println("</div>");
        
        out.println("<script>");
        out.println("console.log('Admin test page loaded');");
        
        // Test form submission
        out.println("document.getElementById('testForm').addEventListener('submit', function(e) {");
        out.println("  e.preventDefault();");
        out.println("  const value = document.getElementById('testInput').value;");
        out.println("  document.getElementById('formResult').innerHTML = '✓ Form submitted with: ' + value;");
        out.println("});");
        
        // Test checklist functionality
        out.println("document.getElementById('showAddForm').addEventListener('click', function() {");
        out.println("  document.getElementById('addForm').style.display = 'block';");
        out.println("});");
        
        out.println("function hideForm() {");
        out.println("  document.getElementById('addForm').style.display = 'none';");
        out.println("  document.getElementById('checklistForm').reset();");
        out.println("}");
        
        out.println("document.getElementById('checklistForm').addEventListener('submit', function(e) {");
        out.println("  e.preventDefault();");
        out.println("  ");
        out.println("  const itemName = document.getElementById('itemName').value;");
        out.println("  const itemBranch = document.getElementById('itemBranch').value;");
        out.println("  ");
        out.println("  console.log('Checklist form submitted:', itemName, itemBranch);");
        out.println("  ");
        out.println("  if (!itemName || !itemBranch) {");
        out.println("    alert('Please fill all fields');");
        out.println("    return;");
        out.println("  }");
        out.println("  ");
        out.println("  // Use URLSearchParams like the fixed version");
        out.println("  const params = new URLSearchParams();");
        out.println("  params.append('itemName', itemName);");
        out.println("  params.append('itemBranch', itemBranch);");
        out.println("  ");
        out.println("  fetch('AddChecklistItem', {");
        out.println("    method: 'POST',");
        out.println("    headers: {");
        out.println("      'Content-Type': 'application/x-www-form-urlencoded',");
        out.println("    },");
        out.println("    body: params");
        out.println("  })");
        out.println("  .then(response => response.json())");
        out.println("  .then(data => {");
        out.println("    console.log('Server response:', data);");
        out.println("    if (data.success) {");
        out.println("      document.getElementById('checklistResult').innerHTML = '✅ Success: ' + data.message;");
        out.println("      hideForm();");
        out.println("    } else {");
        out.println("      document.getElementById('checklistResult').innerHTML = '❌ Error: ' + data.message;");
        out.println("    }");
        out.println("  })");
        out.println("  .catch(error => {");
        out.println("    console.error('Error:', error);");
        out.println("    document.getElementById('checklistResult').innerHTML = '❌ Network error: ' + error.message;");
        out.println("  });");
        out.println("  ");
        out.println("  return false;");
        out.println("});");
        
        out.println("</script>");
        
        out.println("<p><a href='DebugChecklist'>← Debug Checklist</a></p>");
        out.println("<p><a href='admin.jsp'>← Try Admin Dashboard</a></p>");
        out.println("</body>");
        out.println("</html>");
    }
}

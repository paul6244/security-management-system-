package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;

@WebServlet("/ComprehensiveDebug")
public class ComprehensiveDebug extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Comprehensive Form Debug</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println("form { border: 1px solid #ccc; padding: 20px; margin: 20px 0; }");
        out.println("input, select, button { padding: 10px; margin: 5px; }");
        out.println("button { background: #007bff; color: white; border: none; cursor: pointer; }");
        out.println("button:hover { background: #0056b3; }");
        out.println("#debug { background: #f8f9fa; border: 1px solid #dee2e6; padding: 15px; margin: 10px 0; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        
        out.println("<h1>🔍 Comprehensive Form Debug</h1>");
        out.println("<p>This page tests all aspects of form submission functionality.</p>");
        
        // Test 1: Simple form with inline JavaScript
        out.println("<div id='debug'>");
        out.println("<h3>Test 1: Inline JavaScript Form</h3>");
        out.println("<form id='testForm1' onsubmit='alert(\"Inline form submitted!\"); return false;'>");
        out.println("  <input type='text' id='input1' placeholder='Test inline JS'>");
        out.println("  <button type='submit'>Test Inline JS</button>");
        out.println("</form>");
        out.println("</div>");
        
        // Test 2: Form with event listener
        out.println("<div id='debug'>");
        out.println("<h3>Test 2: Event Listener Form</h3>");
        out.println("<form id='testForm2'>");
        out.println("  <input type='text' id='input2' placeholder='Test event listener'>");
        out.println("  <button type='submit'>Test Event Listener</button>");
        out.println("</form>");
        out.println("<div id='result2'></div>");
        out.println("</div>");
        
        // Test 3: Form similar to admin checklist
        out.println("<div id='debug'>");
        out.println("<h3>Test 3: Checklist-Style Form</h3>");
        out.println("<form id='checklistTestForm'>");
        out.println("  <div class='form-group'>");
        out.println("    <label>Item Name:</label>");
        out.println("    <input type='text' id='testItemName' name='itemName' placeholder='Enter item name' required>");
        out.println("  </div>");
        out.println("  <div class='form-group'>");
        out.println("    <label>Branch:</label>");
        out.println("    <select id='testBranch' name='itemBranch' required>");
        out.println("      <option value=''>Select Branch</option>");
        out.println("      <option value='37'>Techiman</option>");
        out.println("      <option value='28'>Accra</option>");
        out.println("      <option value='29'>Kumasi</option>");
        out.println("    </select>");
        out.println("  </div>");
        out.println("  <button type='submit'>Add Test Item</button>");
        out.println("</form>");
        out.println("<div id='result3'></div>");
        out.println("</div>");
        
        // Test 4: Direct button click test
        out.println("<div id='debug'>");
        out.println("<h3>Test 4: Direct Button Click</h3>");
        out.println("<button id='testButton' onclick='alert(\"Button clicked!\")'>Test Click</button>");
        out.println("<button id='testButton2'>Test Event Listener Button</button>");
        out.println("<div id='result4'></div>");
        out.println("</div>");
        
        out.println("<script>");
        out.println("console.log('=== COMPREHENSIVE DEBUG START ===');");
        
        // Test 2: Event listener form
        out.println("document.getElementById('testForm2').addEventListener('submit', function(e) {");
        out.println("  e.preventDefault();");
        out.println("  console.log('Test 2: Event listener form submitted');"); 
        out.println("  const value = document.getElementById('input2').value;");
        out.println("  document.getElementById('result2').innerHTML = '✓ Event listener works! Value: ' + value;");
        out.println("  return false;");
        out.println("});");
        
        // Test 3: Checklist-style form
        out.println("document.getElementById('checklistTestForm').addEventListener('submit', function(e) {");
        out.println("  e.preventDefault();");
        out.println("  console.log('Test 3: Checklist form submitted');");
        out.println("  const itemName = document.getElementById('testItemName').value;");
        out.println("  const branch = document.getElementById('testBranch').value;");
        out.println("  console.log('itemName:', itemName, 'branch:', branch);");
        out.println("  ");
        out.println("  if (!itemName || !branch) {");
        out.println("    document.getElementById('result3').innerHTML = '❌ Please fill all fields';");
        out.println("    return false;");
        out.println("  }");
        out.println("  ");
        out.println("  // Simulate form submission");
        out.println("  document.getElementById('result3').innerHTML = '✓ Checklist form works! Item: ' + itemName + ', Branch: ' + branch;");
        out.println("  ");
        out.println("  // Test fetch to AddChecklistItem");
        out.println("  const params = new URLSearchParams();");
        out.println("  params.append('itemName', itemName);");
        out.println("  params.append('itemBranch', branch);");
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
        out.println("      document.getElementById('result3').innerHTML += '<br>✓ Server success: ' + data.message;");
        out.println("    } else {");
        out.println("      document.getElementById('result3').innerHTML += '<br>❌ Server error: ' + data.message;");
        out.println("    }");
        out.println("  })");
        out.println("  .catch(error => {");
        out.println("    console.error('Fetch error:', error);");
        out.println("    document.getElementById('result3').innerHTML += '<br>❌ Network error: ' + error.message;");
        out.println("  });");
        out.println("  ");
        out.println("  return false;");
        out.println("});");
        
        // Test 4: Button event listeners
        out.println("document.getElementById('testButton2').addEventListener('click', function() {");
        out.println("  console.log('Test 4: Button clicked via event listener');");
        out.println("  document.getElementById('result4').innerHTML = '✓ Button event listener works!';");
        out.println("});");
        
        // Test DOM readiness
        out.println("document.addEventListener('DOMContentLoaded', function() {");
        out.println("  console.log('DOM fully loaded and parsed');");
        out.println("  ");
        out.println("  // Test if all elements exist");
        out.println("  const elements = [");
        out.println("    'testForm1', 'testForm2', 'checklistTestForm', ");
        out.println("    'testButton', 'testButton2',");
        out.println("    'input1', 'input2', 'testItemName', 'testBranch'");
        out.println("  ];");
        out.println("  ");
        out.println("  elements.forEach(id => {");
        out.println("    const element = document.getElementById(id);");
        out.println("    console.log('Element ' + id + ' exists:', !!element);");
        out.println("    if (!element) {");
        out.println("      console.error('❌ Missing element:', id);");
        out.println("    }");
        out.println("  });");
        out.println("  ");
        out.println("  console.log('=== COMPREHENSIVE DEBUG READY ===');");
        out.println("});");
        
        out.println("</script>");
        
        out.println("<h2>📋 Debug Instructions:</h2>");
        out.println("<ol>");
        out.println("<li>Open browser console (F12) to see debug messages</li>");
        out.println("<li>Test each form/button to see what works</li>");
        out.println("<li>Check console for any JavaScript errors</li>");
        out.println("<li>If Test 3 works, the issue is in admin.jsp specifically</li>");
        out.println("<li>If Test 3 fails, the issue is with the AddChecklistItem servlet</li>");
        out.println("</ol>");
        
        out.println("<p><a href='admin.jsp'>← Return to Admin Dashboard</a></p>");
        out.println("</body>");
        out.println("</html>");
    }
}

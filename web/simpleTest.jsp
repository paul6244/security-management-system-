<%@ page import="java.sql.*" %>
<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Simple Checklist Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .form-container { background: #f8f9fa; padding: 20px; border-radius: 8px; max-width: 600px; }
        .form-group { margin: 15px 0; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        select, input { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        button { background: #007bff; color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #0056b3; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <div class="form-container">
        <h1>🧪 Simple Checklist Test</h1>
        <p>This is a minimal test to bypass all form issues.</p>
        
        <%
        String message = request.getParameter("message");
        String status = request.getParameter("status");
        
        if(message != null) {
            if("success".equals(status)) {
                out.println("<div class='success'>" + message + "</div>");
            } else {
                out.println("<div class='error'>" + message + "</div>");
            }
        }
        %>
        
        <form action="SimpleTest" method="post">
            <h3>Test Checklist Items</h3>
            
            <div class="form-group">
                <label for="item1">Gate Locked:</label>
                <select name="item_1" id="item1" required>
                    <option value="OK" selected>OK</option>
                    <option value="NOT_OK">NOT_OK</option>
                </select>
                <input type="text" name="reason_1" placeholder="Reason if NOT_OK">
            </div>
            
            <div class="form-group">
                <label for="item2">Lights Working:</label>
                <select name="item_2" id="item2" required>
                    <option value="OK" selected>OK</option>
                    <option value="NOT_OK">NOT_OK</option>
                </select>
                <input type="text" name="reason_2" placeholder="Reason if NOT_OK">
            </div>
            
            <div class="form-group">
                <label for="item3">CCTV Active:</label>
                <select name="item_3" id="item3" required>
                    <option value="OK" selected>OK</option>
                    <option value="NOT_OK">NOT_OK</option>
                </select>
                <input type="text" name="reason_3" placeholder="Reason if NOT_OK">
            </div>
            
            <button type="submit">🚀 Submit Simple Test</button>
        </form>
        
        <hr>
        
        <h3>🔍 Alternative Approaches to Try:</h3>
        
        <h4>1. Direct Database Test</h4>
        <form action="testDatabase.jsp" method="get">
            <button type="submit">🗄️ Test Database Connection</button>
        </form>
        
        <h4>2. Check Personnel Records</h4>
        <form action="debugPersonnel.jsp" method="get">
            <button type="submit">👤 Debug Personnel Records</button>
        </form>
        
        <h4>3. Back to Main Dashboard</h4>
        <form action="personnelDashboard.jsp" method="get">
            <button type="submit">🏠 Main Dashboard</button>
        </form>
        
        <div style="margin-top: 30px; padding: 15px; background: #fff3cd; border-radius: 5px;">
            <h4>💡 What This Test Does:</h4>
            <ul>
                <li><strong>No JavaScript</strong> - Pure HTML form</li>
                <li><strong>No complex CSS</strong> - Basic styling only</li>
                <li><strong>No form interference</strong> - Only one form on page</li>
                <li><strong>Default values</strong> - All items default to "OK"</li>
                <li><strong>Direct submission</strong> - Straight to SaveChecklist servlet</li>
            </ul>
            
            <p><strong>If this simple test fails, the issue is in the servlet or database, not the form.</strong></p>
        </div>
    </div>
</body>
</html>

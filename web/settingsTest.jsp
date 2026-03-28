<%@ page import="java.sql.*" %>
<%@ page import="config.DatabaseConfig" %>

<%
if(session.getAttribute("username") == null){
    response.sendRedirect("index.jsp");
}

String username = session.getAttribute("username") != null ? session.getAttribute("username").toString() : "";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Settings Functionality Test - Security Management System</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .success { color: #155724; background: #d4edda; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { color: #721c24; background: #f8d7da; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .test-button { background: #28a745; color: white; padding: 10px 20px; text-decoration: none; border: none; border-radius: 4px; cursor: pointer; margin: 10px 5px; display: inline-block; }
        .test-button:hover { background: #218838; }
        .servlet-list { margin: 20px 0; }
        .servlet-item { background: #e9ecef; padding: 10px; margin: 5px 0; border-radius: 4px; }
        .working { color: #27ae60; font-weight: bold; }
        .broken { color: #dc3545; font-weight: bold; }
    </style>
</head>
<body>

<h1>Settings Functionality Test</h1>

<div class="test-section">
    <h2>Available Settings Servlets</h2>
    <div class="servlet-list">
        <div class="servlet-item">✅ UpdateSecuritySettings - Password changes</div>
        <div class="servlet-item">✅ UpdateSecurityOfficerSettings - Profile updates</div>
        <div class="servlet-item">✅ UpdateSystemSettings - System configuration</div>
        <div class="servlet-item">✅ UpdateShiftPreferences - Shift preferences</div>
        <div class="servlet-item">✅ UpdateNotificationSettings - Notification preferences</div>
        <div class="servlet-item">✅ UpdateDashboardSettings - Dashboard preferences</div>
        <div class="servlet-item">✅ UpdateUserIdMismatch - User ID fixes</div>
        <div class="servlet-item">✅ FixUserIdMismatch - User ID mismatch tool</div>
    </div>
</div>

<div class="test-section">
    <h2>Test All Settings Functions</h2>
    <p>Click each button below to test the corresponding settings functionality:</p>
    
    <a href="securityOfficerSettings.jsp" class="test-button">🔧 Open Settings Page</a>
    
    <div style="margin-top: 30px;">
        <h3>Quick Test Links</h3>
        <p><strong>Test Results:</strong></p>
        <ul>
            <li><strong>Settings Page:</strong> Should load without errors</li>
            <li><strong>User Settings Tab:</strong> Password change and profile updates should work</li>
            <li><strong>System Settings Tab:</strong> System configuration should save</li>
            <li><strong>CSRF Protection:</strong> All forms should be protected</li>
            <li><strong>Success Messages:</strong> Green confirmations should appear</li>
            <li><strong>Error Messages:</strong> Red errors should show when needed</li>
            <li><strong>Redirects:</strong> After successful save, should redirect back to settings with success message</li>
        </ul>
    </div>
</div>

<div class="test-section">
    <h2>Expected Behavior</h2>
    <ol>
        <li>✅ <strong>Page Loads:</strong> Settings page should display without compilation errors</li>
        <li>✅ <strong>Tabs Work:</strong> Clicking tabs should switch between User Settings and System Settings</li>
        <li>✅ <strong>Forms Submit:</strong> All save buttons should submit to their respective servlets</li>
        <li>✅ <strong>CSRF Protection:</strong> Forms should have hidden tokens that are validated</li>
        <li>✅ <strong>Success Feedback:</strong> Green success messages should appear when settings are saved</li>
        <li>✅ <strong>Error Handling:</strong> Red error messages should appear for invalid submissions</li>
        <li>✅ <strong>Redirects:</strong> After successful save, should redirect back to settings with success message</li>
    </ol>
</div>

<div class="test-section">
    <h2>Troubleshooting</h2>
    <p><strong>If buttons don't work:</strong></p>
    <ul>
        <li>Check browser console for JavaScript errors</li>
        <li>Verify all servlets are deployed and accessible</li>
        <li>Check network tab in browser developer tools for failed requests</li>
        <li>Use the diagnostic tools: <a href="simpleDiagnosis.jsp">Simple Diagnosis</a> or <a href="completeDiagnosis.jsp">Complete Diagnosis</a></li>
        <li>Contact administrator with specific error details</li>
    </ul>
</div>

</body>
</html>

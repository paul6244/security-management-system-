<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="java.io.ByteArrayOutputStream" %>
<%@ page import="java.io.File" %>
<%@ page import="javax.imageio.ImageIO" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="java.util.Base64" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<title>QR Code Generator</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    margin:0;
    background:#f4f6f9;
}

.navbar {
    background:#1e2a38;
    color:white;
    padding:15px;
    font-size:20px;
    text-align:center;
}

.container {
    display:flex;
    min-height:calc(100vh - 60px);
}

.sidebar {
    width:220px;
    background:#2c3e50;
    color:white;
}

.sidebar a {
    display:block;
    padding:15px;
    color:white;
    text-decoration:none;
}

.sidebar a:hover {
    background:#34495e;
}

.main {
    flex:1;
    padding:20px;
}

.qr-container {
    max-width:800px;
    margin:0 auto;
    background:white;
    padding:30px;
    border-radius:15px;
    box-shadow:0 4px 20px rgba(0,0,0,0.1);
}

.user-grid {
    display:grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap:20px;
    margin-top:20px;
}

.user-card {
    background:#f8f9fa;
    border-radius:10px;
    padding:20px;
    text-align:center;
    border:1px solid #e9ecef;
    transition:transform 0.2s;
}

.user-card:hover {
    transform:translateY(-2px);
    box-shadow:0 4px 12px rgba(0,0,0,0.1);
}

.user-name {
    font-weight:600;
    color:#2c3e50;
    margin-bottom:10px;
}

.user-role {
    color:#7f8c8d;
    font-size:14px;
    margin-bottom:15px;
}

.qr-code {
    width:150px;
    height:150px;
    margin:0 auto 15px;
    border:1px solid #ddd;
    border-radius:8px;
    background:white;
}

.btn {
    padding:8px 16px;
    border:none;
    background:#3498db;
    color:white;
    border-radius:6px;
    cursor:pointer;
    font-size:14px;
    margin:5px;
}

.btn-success {
    background:#27ae60;
}

.btn:hover {
    opacity:0.9;
}

.status-message {
    padding:15px;
    border-radius:10px;
    margin-bottom:20px;
    display:none;
}

.status-success {
    background:#d4edda;
    color:#155724;
    border:1px solid #c3e6cb;
}

.status-error {
    background:#f8d7da;
    color:#721c24;
    border:1px solid #f5c6cb;
}

</style>
</head>

<body>

<div class="navbar">
    QR Code Generator | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="attendance.jsp">Attendance</a>
    <a href="qrGenerator.jsp">QR Generator</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<div class="qr-container">

<h2>Generate QR Codes for Users</h2>

<!-- Status Messages -->
<div id="statusMessage" class="status-message"></div>

<div style="text-align:center; margin-bottom:30px;">
    <button class="btn btn-success" onclick="generateAllQRCodes()">Generate All QR Codes</button>
    <button class="btn" onclick="downloadAllQRCodes()">Download All QR Codes</button>
</div>

<!-- User Grid -->
<div class="user-grid" id="userGrid">

<%
ResultSet rs = Mymodel.getAllUsers();
while(rs != null && rs.next()){
    String username = rs.getString("username");
    String email = rs.getString("email");
    int userId = rs.getInt("id");
%>

<div class="user-card" id="user_<%= userId %>">
    <div class="user-name"><%= username %></div>
    <div class="user-role"><%= email %></div>
    
    <div class="qr-code" id="qr_<%= userId %>">
        <div style="padding:50px 10px; color:#999; font-size:12px;">
            Click "Generate" to create QR code
        </div>
    </div>
    
    <button class="btn" onclick="generateQRCode(<%= userId %>, '<%= username %>')">
        Generate
    </button>
    <button class="btn" onclick="downloadQRCode(<%= userId %>, '<%= username %>')" id="download_<%= userId %>" style="display:none;">
        Download
    </button>
</div>

<%
}
if(rs != null) rs.close();
%>

</div>

</div>

</div>
</div>

<script>

function showStatus(message, type) {
    const statusDiv = document.getElementById('statusMessage');
    statusDiv.className = 'status-message status-' + type;
    statusDiv.textContent = message;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
        statusDiv.style.display = 'none';
    }, 3000);
}

function generateQRCode(userId, username) {
    // Create QR code content
    const qrContent = userId.toString();
    
    // Use QR Server API (more reliable than Google Charts)
    const qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' + encodeURIComponent(qrContent);
    
    const qrDiv = document.getElementById('qr_' + userId);
    qrDiv.innerHTML = '<img src="' + qrUrl + '" alt="QR Code for ' + username + '" style="width:100%; height:100%; border-radius:8px;">';
    
    // Show download button
    document.getElementById('download_' + userId).style.display = 'inline-block';
    
    showStatus('QR code generated for ' + username, 'success');
}

function generateAllQRCodes() {
    const userCards = document.querySelectorAll('.user-card');
    let generated = 0;
    
    userCards.forEach(card => {
        const userId = card.id.replace('user_', '');
        const username = card.querySelector('.user-name').textContent;
        
        // Create QR code content
        const qrContent = userId;
        const qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' + encodeURIComponent(qrContent);
        
        const qrDiv = card.querySelector('.qr-code');
        qrDiv.innerHTML = '<img src="' + qrUrl + '" alt="QR Code for ' + username + '" style="width:100%; height:100%; border-radius:8px;">';
        
        // Show download button
        const downloadBtn = card.querySelector('[id^="download_"]');
        if(downloadBtn) {
            downloadBtn.style.display = 'inline-block';
        }
        
        generated++;
    });
    
    showStatus('Generated ' + generated + ' QR codes successfully!', 'success');
}

function downloadQRCode(userId, username) {
    const qrImg = document.querySelector('#qr_' + userId + ' img');
    
    if(qrImg) {
        const link = document.createElement('a');
        link.href = qrImg.src;
        link.download = 'QR_' + username + '_' + userId + '.png';
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        showStatus('Downloaded QR code for ' + username, 'success');
    }
}

function downloadAllQRCodes() {
    const qrImages = document.querySelectorAll('.qr-code img');
    let downloaded = 0;
    
    qrImages.forEach((img, index) => {
        setTimeout(() => {
            const userCard = img.closest('.user-card');
            const username = userCard.querySelector('.user-name').textContent;
            const userId = userCard.id.replace('user_', '');
            
            const link = document.createElement('a');
            link.href = img.src;
            link.download = 'QR_' + username + '_' + userId + '.png';
            link.target = '_blank';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
            downloaded++;
            
            if(downloaded === qrImages.length) {
                showStatus('Downloaded ' + downloaded + ' QR codes successfully!', 'success');
            }
        }, index * 200); // Delay between downloads
    });
}

// Auto-generate QR codes on page load
window.onload = function() {
    setTimeout(() => {
        generateAllQRCodes();
    }, 1000);
};

</script>

</body>
</html>

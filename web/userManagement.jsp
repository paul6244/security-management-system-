<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>

<%
    if(session.getAttribute("username") == null){
        response.sendRedirect("index.jsp");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>User Management - Security System</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        .user-management-container {
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .section-header {
            background: #2c3e50;
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .search-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .search-container {
            display: flex;
            gap: 10px;
            align-items: center;
            max-width: 600px;
            margin: 0 auto;
        }
        
        #searchInput {
            flex: 1;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .search-btn, .clear-btn {
            padding: 12px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        
        .search-btn {
            background-color: #3498db;
            color: white;
        }
        
        .search-btn:hover {
            background-color: #2980b9;
        }
        
        .clear-btn {
            background-color: #95a5a6;
            color: white;
        }
        
        .clear-btn:hover {
            background-color: #7f8c8d;
        }
        
        .user-table {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .user-table table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .user-table th, .user-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        .user-table th {
            background-color: #2c3e50;
            color: white;
            font-weight: bold;
        }
        
        .user-table tr:hover {
            background-color: #f5f5f5;
        }
        
        .action-btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            margin: 0 2px;
            transition: background-color 0.3s;
        }
        
        .remove-btn {
            background-color: #e74c3c;
            color: white;
        }
        
        .remove-btn:hover {
            background-color: #c0392b;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-inactive {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        
        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 30px;
            border-radius: 8px;
            width: 400px;
            text-align: center;
        }
        
        .modal-buttons {
            margin-top: 20px;
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        
        .confirm-btn {
            background-color: #e74c3c;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        
        .cancel-btn {
            background-color: #95a5a6;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: none;
        }
        
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: none;
        }
    </style>
</head>
<body>
<div class="container">
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="logo">Security System</div>
        <div class="nav">
            <a href="admin.jsp">Dashboard</a>
            <a href="userManagement.jsp" class="active">Users</a>
            <a href="reports.jsp">Reports</a>
            <a href="settings.jsp">Settings</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="user-management-container">
            <!-- HEADER -->
            <div class="section-header">
                <h1>User Management</h1>
                <p>Manage security personnel and system users</p>
            </div>

            <!-- SUCCESS/ERROR MESSAGES -->
            <div id="successMessage" class="success-message">
                Personnel removed successfully!
            </div>
            <div id="errorMessage" class="error-message">
                Error removing personnel. Please try again.
            </div>

            <!-- SEARCH SECTION -->
            <div class="search-section">
                <div class="search-container">
                    <input type="text" id="searchInput" placeholder="Search personnel by name, email, or branch..." onkeyup="searchUsers()">
                    <button class="search-btn" onclick="searchUsers()">Search</button>
                    <button class="clear-btn" onclick="clearSearch()">Clear</button>
                </div>
            </div>

            <!-- USER TABLE -->
            <div class="user-table">
                <table>
                    <thead>
                        <tr>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Branch</th>
                            <th>Shift Time</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="userTableBody">
                        <%
                            ResultSet rs = Mymodel.getAllPersonnel();
                            if(rs != null) {
                                while(rs.next()){
                        %>
                        <tr class="user-row">
                            <td class="username"><%= rs.getString("username") %></td>
                            <td class="email"><%= rs.getString("email") %></td>
                            <td>Security Officer</td>
                            <td class="branch"><%= rs.getString("branch_name") %></td>
                            <td class="shift-time"><%= rs.getString("shift_time") %></td>
                            <td><span class="status-badge status-active">Active</span></td>
                            <td>
                                <button class="action-btn remove-btn" onclick="confirmRemove('<%= rs.getString("username") %>', '<%= rs.getString("email") %>')">Remove</button>
                            </td>
                        </tr>
                        <%
                                }
                                rs.close();
                            } else {
                        %>
                        <tr>
                            <td colspan="7" style="text-align: center; color: #666;">No personnel found.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- REMOVE CONFIRMATION MODAL -->
<div id="removeModal" class="modal">
    <div class="modal-content">
        <h3>Remove Personnel</h3>
        <p>Are you sure you want to remove this personnel?</p>
        <div style="margin: 20px 0; text-align: left; background: #f8f9fa; padding: 15px; border-radius: 4px;">
            <strong>Username:</strong> <span id="removeUsername"></span><br>
            <strong>Email:</strong> <span id="removeEmail"></span>
        </div>
        <p style="color: #e74c3c; font-size: 14px;">This action cannot be undone.</p>
        <div class="modal-buttons">
            <button class="confirm-btn" onclick="removePersonnel()">Remove</button>
            <button class="cancel-btn" onclick="closeModal()">Cancel</button>
        </div>
    </div>
</div>

<script>
    let currentUsername = '';
    let currentEmail = '';

    function searchUsers() {
        const input = document.getElementById('searchInput');
        const filter = input.value.toLowerCase();
        const table = document.getElementById('userTableBody');
        const rows = table.getElementsByTagName('tr');
        
        let visibleCount = 0;
        
        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            const cells = row.getElementsByTagName('td');
            let found = false;
            
            for (let j = 0; j < cells.length; j++) {
                const cellText = cells[j].textContent || cells[j].innerText;
                if (cellText.toLowerCase().indexOf(filter) > -1) {
                    found = true;
                    break;
                }
            }
            
            if (found) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        }
        
        showSearchResults(visibleCount);
    }

    function clearSearch() {
        document.getElementById('searchInput').value = '';
        searchUsers();
    }

    function showSearchResults(count) {
        const existingMsg = document.getElementById('searchMessage');
        if (existingMsg) {
            existingMsg.remove();
        }
        
        if (count === 0) {
            const table = document.getElementById('userTableBody');
            const message = document.createElement('tr');
            message.id = 'searchMessage';
            message.innerHTML = '<td colspan="7" style="text-align: center; padding: 20px; color: #666;">No personnel found matching your search criteria.</td>';
            table.appendChild(message);
        }
    }

    function confirmRemove(username, email) {
        currentUsername = username;
        currentEmail = email;
        document.getElementById('removeUsername').textContent = username;
        document.getElementById('removeEmail').textContent = email;
        document.getElementById('removeModal').style.display = 'block';
    }

    function closeModal() {
        document.getElementById('removeModal').style.display = 'none';
        currentUsername = '';
        currentEmail = '';
    }

    function removePersonnel() {
        // Create AJAX request to remove personnel
        const xhr = new XMLHttpRequest();
        xhr.open('POST', 'RemovePersonnel', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    const response = xhr.responseText;
                    if (response.includes('success')) {
                        showMessage('successMessage');
                        // Remove the row from table
                        const rows = document.getElementById('userTableBody').getElementsByTagName('tr');
                        for (let i = 0; i < rows.length; i++) {
                            const usernameCell = rows[i].getElementsByClassName('username')[0];
                            if (usernameCell && usernameCell.textContent === currentUsername) {
                                rows[i].remove();
                                break;
                            }
                        }
                    } else {
                        showMessage('errorMessage');
                    }
                } else {
                    showMessage('errorMessage');
                }
                closeModal();
            }
        };
        
        const params = 'username=' + encodeURIComponent(currentUsername) + '&email=' + encodeURIComponent(currentEmail);
        xhr.send(params);
    }

    function showMessage(messageId) {
        const message = document.getElementById(messageId);
        message.style.display = 'block';
        setTimeout(() => {
            message.style.display = 'none';
        }, 5000);
    }

    // Search on Enter key
    document.getElementById('searchInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchUsers();
        }
    });

    // Close modal when clicking outside
    window.onclick = function(event) {
        const modal = document.getElementById('removeModal');
        if (event.target === modal) {
            closeModal();
        }
    }
</script>

</body>
</html>

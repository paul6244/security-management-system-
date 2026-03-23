// ========================================
// BACKUP OF ORIGINAL CONNECTION
// ========================================
// Keep this as backup in case you need to restore

private static final String ORIGINAL_URL = "jdbc:mysql://localhost:3306/securitymanagementsystem";
private static final String ORIGINAL_USER = "root";
private static final String ORIGINAL_PASSWORD = "";

// ========================================
// RAILWAY CONNECTION TEMPLATE
// ========================================
// Replace lines 10-12 in Mymodel.java with these:

// After you get Railway connection string, it will look like:
// mysql://username:password@host.railway.app:3306/database

// Update to:
private static final String URL = "jdbc:mysql://YOUR_RAILWAY_HOST:3306/YOUR_DATABASE";
private static final String USER = "YOUR_RAILWAY_USERNAME";
private static final String PASSWORD = "YOUR_RAILWAY_PASSWORD";

// ========================================
// EXAMPLE AFTER RAILWAY SETUP:
// ========================================
// private static final String URL = "jdbc:mysql://containers-us-west-123.railway.app:3306/railway";
// private static final String USER = "root";
// private static final String PASSWORD = "your-password-from-railway";

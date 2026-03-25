# Security Management System

A web-based security management system for personnel tracking, attendance, and incident reporting.

## Features

- User authentication and role-based access
- Personnel management and registration
- QR code-based attendance tracking
- Shift management and reporting
- Real-time dashboard with statistics
- Incident reporting and tracking
- Branch management

## Technology Stack

- **Backend**: Java Servlets, JSP
- **Database**: MySQL (local), PostgreSQL (Heroku)
- **Build Tool**: Maven
- **Deployment**: Heroku

## Local Development

### Prerequisites

- Java 11 or higher
- Maven 3.6+
- MySQL Server
- Apache Tomcat (optional, for local testing)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd SecurityManagementSystem
   ```

2. **Database Setup**
   - Create a MySQL database named `securitymanagementsystem`
   - Import the provided SQL schema: `create_staff_table.sql`
   - Update database credentials in `src/java/model/Mymodel.java` if needed

3. **Build the project**
   ```bash
   mvn clean install
   ```

4. **Run locally**
   ```bash
   mvn tomcat7:run
   ```
   Or deploy the generated WAR file to your Tomcat server.

## Heroku Deployment

### Prerequisites

- Heroku CLI
- Heroku account

### Deployment Steps

1. **Login to Heroku**
   ```bash
   heroku login
   ```

2. **Create Heroku app**
   ```bash
   heroku create your-app-name
   ```

3. **Add PostgreSQL database**
   ```bash
   heroku addons:create heroku-postgresql:hobby-dev
   ```

4. **Deploy to Heroku**
   ```bash
   git add .
   git commit -m "Deploy to Heroku"
   git push heroku master
   ```

5. **Open the application**
   ```bash
   heroku open
   ```

### Environment Variables

The application automatically detects Heroku's `DATABASE_URL` environment variable for database connection. For local development, it falls back to MySQL configuration.

## Project Structure

```
SecurityManagementSystem/
├── src/
│   └── java/
│       ├── config/          # Database configuration
│       ├── model/           # Data models and database operations
│       ├── servlet/         # HTTP request handlers
│       └── utility/         # Utility classes
├── web/
│   ├── WEB-INF/
│   ├── css/                 # Stylesheets
│   ├── image/               # Images and assets
│   └── *.jsp               # JSP pages
├── pom.xml                  # Maven configuration
├── Procfile                 # Heroku process configuration
├── system.properties        # Java version specification
└── README.md               # This file
```

## Database Schema

The application uses the following main tables:

- `users` - User accounts and authentication
- `security_personnel` - Security officer details
- `branches` - Branch/office locations
- `shifts` - Work shift records
- `attendance` - Attendance tracking
- `shift_checks` - Security checklist items
- `checklist_items` - Available checklist items

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

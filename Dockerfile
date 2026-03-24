# Use OpenJDK 11 as base image
FROM openjdk:11-jdk-slim

# Set working directory
WORKDIR /app

# Copy MySQL connector JAR
COPY mysql-connector-java-8.0.33.jar /app/

# Copy the compiled WAR file (assuming you'll build it as SecurityManagementSystem.war)
COPY SecurityManagementSystem.war /app/

# Install Tomcat
RUN apt-get update && \
    apt-get install -y tomcat9 && \
    apt-get clean

# Deploy the WAR file to Tomcat
RUN cp SecurityManagementSystem.war /var/lib/tomcat9/webapps/

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

@echo off
echo Building Security Management System for deployment...

REM Clean previous builds
if exist "dist" rmdir /s /q "dist"
mkdir "dist"

REM Copy necessary files
copy "web\*" "dist\" /Y
copy "src\*" "dist\src\" /Y
copy "lib\*" "dist\lib\" /Y 2>nul
copy "mysql-connector-java-8.0.33.jar" "dist\" /Y 2>nul

REM Check if MySQL connector exists
if not exist "dist\mysql-connector-java-8.0.33.jar" (
    echo WARNING: mysql-connector-java-8.0.33.jar not found!
    echo Please download MySQL Connector JAR and place it in the project root
    pause
)

REM Create WAR file structure
mkdir "dist\WEB-INF"
mkdir "dist\WEB-INF\classes"
mkdir "dist\WEB-INF\lib"

REM Copy web files
xcopy "dist\*.jsp" "dist\WEB-INF\" /Y 2>nul
xcopy "dist\*.css" "dist\WEB-INF\" /Y 2>nul
xcopy "dist\*.js" "dist\WEB-INF\" /Y 2>nul

echo Build completed!
echo Next steps:
echo 1. Push to GitHub
echo 2. Connect to Vercel
echo 3. Deploy!

pause

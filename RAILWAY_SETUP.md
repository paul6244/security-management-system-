# 🚀 RAILWAY SETUP GUIDE
# 100% Free Database for Your Security Management System

## 📋 Step 1: Create Railway Account (2 minutes)

1. Go to **https://railway.app**
2. Click **"Login with GitHub"**
3. Authorize GitHub access
4. Railway account created automatically!

## 🗄️ Step 2: Create MySQL Database (3 minutes)

1. In Railway dashboard, click **"+ New Project"**
2. Select **"Provision MySQL"**
3. Project name: `security-management-db`
4. Click **"Add MySQL Database"**
5. Wait 30 seconds for database to be ready

## 🔗 Step 3: Get Connection String (1 minute)

1. Click on your new MySQL database
2. Go to **"Connect"** tab
3. Copy the **Connection String**
4. It looks like: `mysql://user:password@host:port/database`

## 📝 Step 4: Update Your Code (2 minutes)

1. Open `src/java/model/Mymodel.java`
2. Find this line:
   ```java
   Connection con = DriverManager.getConnection(
       "jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
   ```
3. Replace with Railway connection:
   ```java
   Connection con = DriverManager.getConnection(
       "jdbc:mysql://your-railway-host.railway.app:3306/railway",
       "your-username", 
       "your-password");
   ```

## 🚀 Step 5: Deploy to GitHub Pages (5 minutes)

1. Push your updated code to GitHub
2. Go to repository settings → Pages
3. Source: "Deploy from branch" → "main"
4. Folder: "/ (root)"
5. Click "Save"

## 🎉 Result: Fully Functional Free App!

- **Website**: `https://yourusername.github.io/SecurityManagementSystem/`
- **Database**: Real MySQL database on Railway
- **Cost**: $0.00/month
- **Features**: All JSP functionality works!

## 🔧 Railway Free Tier Limits:
- **Storage**: 1GB (enough for your app)
- **Bandwidth**: 100GB/month (plenty)
- **CPU**: 240 hours/month (sufficient)
- **Sleeps**: After 30min inactivity (wakes on request)

## 🛠️ Troubleshooting:
- **Database not connecting?** Check connection string format
- **Website not updating?** Clear GitHub Pages cache
- **Sleeping database?** Just visit your website to wake it

## 🎯 You're Ready to Go!
Your Security Management System will be 100% free and fully functional online!

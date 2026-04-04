package config;

public class SMSConfig {
    // Twilio Configuration - Replace with your actual credentials
    public static final String ACCOUNT_SID = "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; // Your Twilio Account SID
    public static final String AUTH_TOKEN = "your_actual_auth_token_here"; // Your Twilio Auth Token
    public static final String TWILIO_NUMBER = "+1234567890"; // Your Twilio phone number
    
    // Set to true to enable real SMS sending
    public static final boolean USE_REAL_SMS = true; // Change to true to send real SMS messages
    
    // Ghana country code for auto-formatting
    public static final String GHANA_COUNTRY_CODE = "+233";
    
    public static boolean isRealSMSEnabled() {
        return USE_REAL_SMS;
    }
    
    public static String getTwilioNumber() {
        return TWILIO_NUMBER;
    }
    
    public static String getAccountSid() {
        return ACCOUNT_SID;
    }
    
    public static String getAuthToken() {
        return AUTH_TOKEN;
    }
    
    // Instructions for setting up Twilio:
    // 1. Sign up at https://www.twilio.com/
    // 2. Get your Account SID and Auth Token from Console
    // 3. Purchase a Twilio phone number or use trial number
    // 4. Replace the placeholder values above with your actual credentials
    // 5. Set USE_REAL_SMS = true to enable real SMS sending
}

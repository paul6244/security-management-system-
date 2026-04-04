package config;

public class SMSConfig {
    // Twilio Configuration (you need to set these values)
    public static final String ACCOUNT_SID = "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; // Your Twilio Account SID
    public static final String AUTH_TOKEN = "your_auth_token_here"; // Your Twilio Auth Token
    public static final String TWILIO_NUMBER = "+1234567890"; // Your Twilio phone number
    
    // For testing, set to true to use real SMS, false to simulate
    public static final boolean USE_REAL_SMS = false; // Change to true for production
    
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
}

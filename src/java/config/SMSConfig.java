package config;

public class SMSConfig {
    // For testing, set to true to use real SMS, false to simulate
    public static final boolean USE_REAL_SMS = false; // Keep false for now until Twilio is properly configured
    
    // Ghana country code for auto-formatting
    public static final String GHANA_COUNTRY_CODE = "+233";
    
    public static boolean isRealSMSEnabled() {
        return USE_REAL_SMS;
    }
    
    // Placeholder for future Twilio configuration
    public static String getTwilioNumber() {
        return "+1234567890"; // Placeholder Twilio number
    }
    
    public static String getAccountSid() {
        return "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; // Placeholder Account SID
    }
    
    public static String getAuthToken() {
        return "your_auth_token_here"; // Placeholder Auth Token
    }
}

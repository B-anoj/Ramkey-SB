public class APILoggerController {
    public static void fetchSAPResponse(Integer statusCode, String response) {
        try {
            API_Logger__c apiLogs = new API_Logger__c();
            apiLogs.status_Code__c = statusCode;
            apiLogs.Response__c = response;
            DataBase.insert(apiLogs, false);
        } Catch (Exception ex) {
            System.debug('Error Message =' + ex.getMessage());
        }
    }

}
@RestResource(urlMapping='/userLogin')
Global class API_UserInfo {
    @HttpGet
    Global static userInfo getUserInfo() {
        userInfo wrap = new userInfo();
        try {
            String email = RestContext.request.params.get('userEmail');
            wrap.customerData = userValidation(email);
        } Catch (Exception ex) {
            System.debug('Error Message ='+ ex.getMessage());
        }
        return wrap;
    }
    public static DataWrapper userValidation(String email) {
        DataWrapper wrapper = new DataWrapper();
        try {
            Integer otp = Math.round((Math.random() * (900000)) + 100000);
            
            List<User> users = [
                SELECT Id, Email, Contact.Email, Name, Phone, Contact.Phone 
                FROM User 
                WHERE Email = :email AND Contact.Email = :email 
                LIMIT 1
            ];
            
            if (!users.isEmpty()) {
                User existMatch = users[0];
                wrapper.otp = otp;
                wrapper.matchedUser = existMatch;
                wrapper.customerValidate = 'Customer Found';
                sendOTPCustomer(existMatch.Email); 
            } else {
                wrapper.customerValidate = 'Customer Not Found';
            }
        } catch (Exception ex) {
            System.debug('Error Message = ' + ex.getMessage());
            wrapper.customerValidate = 'Error Occurred';
        }
        return wrapper;
    }
    public static void sendOTPCustomer(String email) {
        try {
            Contact existMatchedCustomer = [SELECT Id, OTP__c FROM Contact WHERE Email =:email];
            Integer otp = Math.round((Math.random() * (900000)) + 100000);
            existMatchedCustomer.OTP__c = otp;
            update existMatchedCustomer;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {email};
                mail.setToAddresses(toAddresses);
            mail.setSubject('OTP for Delivery');
            String body = '<b>Dear Customer'+ '</b>,<br/><br/>';
            body += 'Your Login OTP :- ' + otp + '<br/><br/>';
            body += 'Regards,<br/>'+ 'Ramky';
            mail.setHtmlBody(body);
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            System.debug('Email Sent Successfully =' + otp);
        } Catch (Exception ex) {
            System.debug('Error Message =' + ex.getMessage());
        }
    }
    @HttpPost
    global static void userDataOperation() {
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.toString();
        userCaseCreation userDetails = (userCaseCreation) JSON.deserialize(reqBody, userCaseCreation.class);

        try {
            importUserIssue(userDetails);
        } catch (Exception ex) {
            System.debug('Error in userDataOperation: ' + ex.getMessage());
        }
    }
    public static void importUserIssue(userCaseCreation data) {
        try {
            Case newCase = new Case();
            newCase.Email__c = data.email;
            newCase.Phone_Number__c = data.phone;
            newCase.Origin = 'Phone';
            newCase.Subject = 'Customer Login Issue';
            newCase.Description = data.description;
            insert newCase;
            System.debug('Case Created: ' + newCase.Id);
        } catch (Exception ex) {
            System.debug('Error in importUserIssue: ' + ex.getMessage());
        }
    }
    Global class userInfo {
        public DataWrapper customerData;
    }
    Global class DataWrapper {
        public integer otp;
        public String customerValidate;
        public User matchedUser;
    }
    Global class userCaseCreation {
        public string email;
        public string phone;
        public string description;
    }

}
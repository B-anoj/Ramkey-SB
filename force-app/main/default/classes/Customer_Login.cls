Global without sharing class Customer_Login {
    Global static void getCustomerDetail() {
        DataWrapper wrapper = new DataWrapper ();
        try {
            String email = RestContext.request.params.get('userEmail');
            wrapper.customerValidation = getUserValidation(email);
        } Catch (Exception ex) {
            System.debug('Error Message =' + ex.getMessage());
        }
    } 
    
    @AuraEnabled
    global static String getUserValidation(String email) {
        String customerValidation = 'Customer Not Found';
        try {
            List<User> userList = [SELECT Id, Email, ContactId, IsActive FROM User WHERE Email =: email AND ContactId != null AND isActive = true LIMIT 1];
            if (!userList.isEmpty()) {
                User existMatched = userList[0];
                if (existMatched.Id != null) {
                    customerValidation = 'Customer Found';
                    sendOTPCustomer(existMatched.Email);
                }
            }
            System.debug('Customer Login =' + customerValidation);
        } catch (Exception ex) {
            System.debug('Error Message =' + ex.getMessage());
        }
        return customerValidation;
        }

    @AuraEnabled
    Global static void sendOTPCustomer(String email) {
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
           // Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            System.debug('Email Sent Successfully =' + otp);
        } Catch (Exception ex) {
            System.debug('Error Message =' + ex.getMessage());
        }
    }
    @AuraEnabled
    Global static String verifyOTP(Integer otp, String email) {
        try {
            Contact customerVerify = [SELECT Id, Email, OTP__c FROM Contact WHERE Email = :email LIMIT 1];
            if (customerVerify.OTP__c == otp) {
                return 'Valid';
            } else {
                return 'Invalid';
            }
        } catch (Exception ex) {
            return 'Error: ' + ex.getMessage();
        }
    }
    @AuraEnabled
    Global static void loginIssue(String email, string phone, String Description) {
        try {
            Case customerLoginCase = new Case();
            customerLoginCase.Email__c = Email;
            customerLoginCase.Phone_Number__c = Phone;
            customerLoginCase.Description = description;
            customerLoginCase.Origin = 'Web'; 
            insert customerLoginCase;
            System.debug('Case Submitted Successfully =' + customerLoginCase);
        } catch (Exception ex) {
            System.debug('Error Message =' + ex.getMessage());
            throw new AuraHandledException('Failed to create support case.');
        }
    }

    Global class DataWrapper {
        public string customerValidation;
    }

    
}
@RestResource(urlMapping='/loginIssue')
global class API_LoginIssueHandler {

    @HttpGet
    global static userInfo getUserInfo() {
        userInfo wrap = new userInfo();
        try {
            String email = RestContext.request.params.get('userEmail');
            if (String.isBlank(email)) {
                wrap.customerData = new DataWrapper();
                wrap.customerData.customerValidate = 'Email is required';
                return wrap;
            }
            wrap.customerData = userValidation(email);
        } catch (Exception ex) {
            System.debug('Error Message = ' + ex.getMessage());
            wrap.customerData = new DataWrapper();
            wrap.customerData.customerValidate = 'Internal Server Error';
        }
        return wrap;
    }

    public static DataWrapper userValidation(String email) {
        DataWrapper wrapper = new DataWrapper();
        try {
            Integer otp = Math.round(Math.random() * 900000 + 100000);

            List<User> users = [
                SELECT Id, Email, Contact.Email, Name 
                FROM User 
                WHERE Email = :email AND Contact.Email = :email 
                LIMIT 1
            ];

            if (!users.isEmpty()) {
                User matchedUser = users[0];
                wrapper.otp = otp;
                wrapper.matchedUser = matchedUser;
                wrapper.customerValidate = 'Customer Found';
            } else {
                wrapper.customerValidate = 'Customer Not Found';
            }
        } catch (Exception ex) {
            System.debug('userValidation error: ' + ex.getMessage());
            wrapper.customerValidate = 'Error Occurred';
        }
        return wrapper;
    }

    @HttpPost
    global static void userDataOperation() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            String reqBody = req.requestBody.toString();

            if (String.isBlank(reqBody)) {
                sendErrorResponse(res, 'Missing request body');
                return;
            }

            // Updated: Deserialize using correct JSON field names
            userCaseCreation userDetails = (userCaseCreation) JSON.deserialize(reqBody, userCaseCreation.class);

            if (String.isBlank(userDetails.email) || String.isBlank(userDetails.issue_description)) {
                sendErrorResponse(res, 'Missing required fields: email or issue_description');
                return;
            }

            Case newCase = new Case(
                Email__c = userDetails.email,
                Phone_Number__c = userDetails.mobile_number,
                Origin = 'Portal',
                Subject = 'Customer Login Issue',
                Description = userDetails.issue_description
            );
            insert newCase;

            LoginIssueResponse response = new LoginIssueResponse(true, 'Case created successfully. Case Id: ' + newCase.Id);
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(response));

        } catch (Exception ex) {
            sendErrorResponse(res, 'Error: ' + ex.getMessage());
        }
    }

    private static void sendErrorResponse(RestResponse res, String message) {
        LoginIssueResponse response = new LoginIssueResponse(false, message);
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    // === Wrapper Classes ===

    global class userCaseCreation {
        public String email;
        public String mobile_number;
        public String issue_description;
    }

    global class LoginIssueResponse {
        public Boolean success;
        public String success_message;

        public LoginIssueResponse(Boolean s, String msg) {
            success = s;
            success_message = msg;
        }
    }

    global class userInfo {
        public DataWrapper customerData;
    }

    global class DataWrapper {
        public Integer otp;
        public String customerValidate;
        public User matchedUser;
    }
}
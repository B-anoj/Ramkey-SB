@RestResource(urlMapping='/getUserDetails')
global class API_GetUserDetails {
	@HttpGet
    global static void getUserData() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            String email = req.params.get('email');
            if (String.isBlank(email)) {
                throw new CalloutException('Missing required parameter: email');
            }

            // Query Contact based on Email (you can change Contact to your object)
            Contact c = [SELECT Id, Name, Phone, Email FROM Contact WHERE Email = :email LIMIT 1];

            UserWrapper user = new UserWrapper(
                c.Id,
                c.Name,
                c.Phone,
                c.Email
            );

            UserResponse response = new UserResponse('success', 'User data retrieved successfully', user);

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));

        } catch (QueryException qe) {
            UserResponse response = new UserResponse('error', 'No user found with the provided email.', null);
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
        } catch (Exception e) {
            UserResponse errorResponse = new UserResponse('error', e.getMessage(), null);
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
        }
    }    
     global class UserWrapper {
        public String user_id;
        public String name;
        public String mobile;
        public String email;

        public UserWrapper(String user_id, String name, String mobile, String email) {
            this.user_id = user_id;
            this.name = name;
            this.mobile = mobile;
            this.email = email;
        }
    }

    global class UserResponse {
        public String status;
        public String message;
        public UserWrapper data;

        public UserResponse(String status, String message, UserWrapper data) {
            this.status = status;
            this.message = message;
            this.data = data;
        }
    }
}
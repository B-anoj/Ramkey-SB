/**
* @File Name : profileController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : July 3, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | July 3, 2025 |   | Initial Version
**/

public without sharing class profileController {
    @AuraEnabled(cacheable=true)
    public static User getCurrentUserDetails(string email) {
        try {
                User currentUser = [SELECT Id, FirstName, LastName, Email, Phone, Username
                    FROM User WHERE email = :email LIMIT 1];
                System.debug('currentUser =======> ' + currentUser);
                return currentUser;
            
        } catch (Exception e) {
            System.debug('Error at Line Number ===> ' + e.getLineNumber() + ' Error message ====> ' + e.getMessage());
        }
        return null;
    }
}
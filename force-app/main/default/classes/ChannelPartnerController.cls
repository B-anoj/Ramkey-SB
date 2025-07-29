public class ChannelPartnerController {
 
    @AuraEnabled
    public static Channel_Partner_Details__c getChannelPartnerDetails(String reraNumber) {
        try {
            List<Channel_Partner_Details__c> cpDetails = [SELECT Company_Individual_Name__c, Contact_Person_Name__c, Email_Address__c,
                                                          Phone_Number__c, Channel_Partner_RERA_Number__c, City__c, Country__c,
                                                          Door_No__c, PINCODE__c, State__c,Street1__c, Street2__c
                                                          FROM Channel_Partner_Details__c
                                                          WHERE Channel_Partner_RERA_Number__c = :reraNumber
                                                          LIMIT 1];
            if (!cpDetails.isEmpty()) {
                return cpDetails[0];
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Channel Partner details: ' + e.getMessage());
        }
    }
 
   @AuraEnabled
public static void saveOpportunityDetails(Id recordId, String CPreraNumber, String CPmobileNumber, String CPemail, String CPcompanyName) {
    try {
        if (recordId == null) {
            throw new AuraHandledException('Error: recordId is null');
        }
 
        Opportunity opp = [
            SELECT Id, RERA_Registration_Number__c, Company_Individual_Name__c, CP_Mobile_Number__c, Email_Address__c, LPP_Days__c, Bypass_LPPDays__c
            FROM Opportunity
            WHERE Id = :recordId
            LIMIT 1
        ];
 
        // Check if LPP_Days__c is less than 60 and any CP fields are populated
        if (opp.LPP_Days__c != null && opp.LPP_Days__c < 60 && !opp.Bypass_LPPDays__c &&
            (!String.isBlank(opp.RERA_Registration_Number__c) ||
             !String.isBlank(opp.Company_Individual_Name__c) ||
             !String.isBlank(opp.CP_Mobile_Number__c) ||
             !String.isBlank(opp.Email_Address__c))) {
                 throw new AuraHandledException('CP Details cannot be updated as LPP Days are less than 60.');
             }
       
       
       
        // Update the Opportunity fields with new details
        opp.CP_Mobile_Number__c = CPmobileNumber;
        opp.Email_Address__c = CPemail;
        opp.Company_Individual_Name__c = CPcompanyName;
        opp.RERA_Registration_Number__c = CPreraNumber;
       
        update opp;
       
    } catch (Exception e) {
        throw new AuraHandledException('CP Details cannot be updated as LPP Days are less than 60 ');
    }
}
   
}
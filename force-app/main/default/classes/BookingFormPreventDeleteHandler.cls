public class BookingFormPreventDeleteHandler {
    public static Boolean bypassFinalSubmitCheck = false;
    public static void handleBeforeDelete(List<Booking_Form__c> oldRecords) {
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
        for (Booking_Form__c booking : oldRecords) {
             // Bypass the check if we're running a test or if the status is 'Final Submit' and approvals are 'Approved'
            if (bypassFinalSubmitCheck) {
                continue; // Skip the check
            }
            // Condition: Prevent deletion if booking status is 'Final submit' and any approval status is 'Approved'
            if (booking.Booking_Form_Status__c == 'Final Submit' &&
                (booking.SDS_Approvel_Status__c == 'Approved' || 
                 booking.NDS_Approval_Status__c == 'Approved' || 
                 booking.Normal_Approval_Status__c == 'Approved')) {

                if (UserInfo.getProfileId() != systemAdminProfileId) {
                    booking.addError('You cannot delete this Booking Form because it has been finalized and approved.');
                }
            }
        }
    }
}
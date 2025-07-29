public with sharing class FeedbackRatingController {
    
   @RemoteAction
    public static String saveRating(String caseId, Integer rating) {
        if (String.isBlank(caseId) || rating == null) {
            return 'Invalid Input';
        }

        try {
            Case caseToUpdate = [SELECT Id, Feedback_Rating__c FROM Case WHERE Id = :caseId LIMIT 1];
            caseToUpdate.Feedback_Rating__c = rating;
            update caseToUpdate;
            return 'Success';
        } catch (Exception ex) {
            return 'Error: ' + ex.getMessage();
        }
    }
}
trigger BookingFormTrigger on Booking_Form__c (before insert, before update, after insert, after update, before delete) {
    // Before Insert/Update logic for updating the country code
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            System.debug('Executing before insert/update logic for updating country codes.');
            UpdateCountryCodeHandler.updateCountryCodes(Trigger.new);
        }
        
        // Before Delete logic to handle BookingFormRevertProductStatusTrigger and BookingFormPreventDeleteTrigger
        if (Trigger.isDelete) {
            if (Trigger.old != null && !Trigger.old.isEmpty()) {
                System.debug('Executing before delete logic for reverting product status and preventing delete.');
                BookingFormRevertProductStatusHandler.handleBeforeDelete(Trigger.old);
                BookingFormPreventDeleteHandler.handleBeforeDelete(Trigger.old);
            }
        }
    }
    
    // After Insert/Update logic for sending email and handling external system data
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            System.debug('Executing after insert/update logic for email creation and external system data handling.');
            BookingFormCreationEmailHandler.handleAfterInsertOrUpdate(Trigger.new);
            
            List<Id> finalSubmitRecordIds = new List<Id>();
            List<Id> sendToSignRecordIds = new List<Id>();
            
            for (Booking_Form__c bookingForm : Trigger.new) {
                System.debug('Processing booking form record: ' + bookingForm);
                
                if (bookingForm.Booking_Form_Status__c == 'Final submit' && bookingForm.Is_Booking_Form_Signed__c == false &&
                    (bookingForm.SDS_Approvel_Status__c == 'Approved' || bookingForm.Normal_Approval_Status__c == 'Approved' ||
                     bookingForm.NDS_Approval_Status__c == 'Approved') &&
                    (Trigger.isInsert ||
                     (Trigger.isUpdate && 
                      (bookingForm.Booking_Form_Status__c != Trigger.oldMap.get(bookingForm.Id).Booking_Form_Status__c ||
                       bookingForm.SDS_Approvel_Status__c != Trigger.oldMap.get(bookingForm.Id).SDS_Approvel_Status__c ||
                       bookingForm.Normal_Approval_Status__c != Trigger.oldMap.get(bookingForm.Id).Normal_Approval_Status__c ||
                       bookingForm.NDS_Approval_Status__c != Trigger.oldMap.get(bookingForm.Id).NDS_Approval_Status__c)))) {
                    sendToSignRecordIds.add(bookingForm.Id);
                    System.debug('Added to sendToSignRecordIds: ' + bookingForm.Id);
                }
                
                if (bookingForm.Booking_Form_Status__c == 'Final submit' && bookingForm.Is_Booking_Form_Signed__c == true &&
                    (bookingForm.SDS_Approvel_Status__c == 'Approved' || bookingForm.Normal_Approval_Status__c == 'Approved' ||
                     bookingForm.NDS_Approval_Status__c == 'Approved') &&
                    (Trigger.isInsert ||
                     (Trigger.isUpdate && 
                      (bookingForm.Is_Booking_Form_Signed__c != Trigger.oldMap.get(bookingForm.Id).Is_Booking_Form_Signed__c)))) {
                    finalSubmitRecordIds.add(bookingForm.Id);
                    System.debug('Added to finalSubmitRecordIds: ' + bookingForm.Id);
                }
            }
            
            if (!sendToSignRecordIds.isEmpty()) {
                System.debug('Scheduling jobs for sendToSignRecordIds: ' + sendToSignRecordIds);
                for (Id bookId : sendToSignRecordIds) {
                    String cronExpression = System.now().addMinutes(1).format('s m H d M \'?\' yyyy');
                    System.debug('Scheduling PdfUplodeSchedulable for bookId: ' + bookId + ' with cron: ' + cronExpression);
                    System.schedule('BJob_' + Datetime.now().getTime() + '_' + bookId, cronExpression, new PdfUplodeSchedulable(bookId));
                   // PdfUploaderService.processBookingFormApproved(bookId);
                }
            }
            
            if (!finalSubmitRecordIds.isEmpty()) {
                System.debug('Scheduling jobs for finalSubmitRecordIds: ' + finalSubmitRecordIds);
                for (Id bookingFormId : finalSubmitRecordIds) {
                    String cronExpression = System.now().addMinutes(2).format('s m H d M \'?\' yyyy');
                    System.debug('Scheduling BookingFormSendDataSchedulable for bookingFormId: ' + bookingFormId + ' with cron: ' + cronExpression);
                    System.schedule('BFormSendDataJob_' + Datetime.now().getTime() + '_' + bookingFormId, cronExpression, new BookingFormSendDataSchedulable(bookingFormId));
                }
            }
        }
    }
}
global class BookingFormSendDataSchedulable implements Schedulable {
    public Id bookingFormId;
    
    // Constructor with log
    public BookingFormSendDataSchedulable(Id bookingFormId) {
        this.bookingFormId = bookingFormId;
        System.debug('BookingFormSendDataSchedulable initialized with bookingFormId: ' + bookingFormId);
    }
    
    global void execute(SchedulableContext ctx) {
        System.debug('BookingFormSendDataSchedulable execution started.');
        //System.debug('SchedulableContext job ID: ' + ctx.getJobId());
        System.debug('Executing processBookingForm for bookingFormId: ' + bookingFormId);
        
        try {
            BookingFormSendData.processBookingForm(bookingFormId);
            System.debug('processBookingForm executed successfully for bookingFormId: ' + bookingFormId);
        } catch (Exception e) {
            System.debug('Error occurred in BookingFormSendDataSchedulable for bookingFormId: ' + bookingFormId);
            System.debug('Error message: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        System.debug('BookingFormSendDataSchedulable execution completed.');
    }
}

/*global class BookingFormSendDataSchedulable implements Schedulable {
    public Id bookingFormId;
    
    public BookingFormSendDataSchedulable(Id bookingFormId) {
        this.bookingFormId = bookingFormId;
    }
    
    global void execute(SchedulableContext ctx) {
        BookingFormSendData.processBookingForm(bookingFormId);
    }
}*/
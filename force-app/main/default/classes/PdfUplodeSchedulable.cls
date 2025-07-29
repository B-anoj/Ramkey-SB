global class PdfUplodeSchedulable implements Schedulable {
 public Id bookId;
    
    public PdfUplodeSchedulable(Id bookId) {
        this.bookId = bookId;
    }
    
    global void execute(SchedulableContext ctx) {
       
        PdfUploaderService.processBookingFormApproved(bookId);
    }
}
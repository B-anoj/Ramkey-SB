Global class QueueSAPDocumentAttachment implements Queueable, Database.AllowsCallouts {
    private List<String> docKeys;
    
    public QueueSAPDocumentAttachment(List<String> docKeys) {
        this.docKeys = docKeys;
    }
    
    public void execute(QueueableContext context) {
        BatchSAPDocumentAttachment.processAttachments(docKeys);
    }
}
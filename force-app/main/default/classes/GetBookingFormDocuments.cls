@RestResource(urlMapping='/BookingFormDocuments/*')
global class GetBookingFormDocuments {
    
    @HttpGet
    global static BookingDocumentResponse DocumentIds() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
		String BFId = req.params.get('bookingFormId');
        BookingDocumentResponse response = new BookingDocumentResponse();  
        if(BFId <> null && BFId <> ''){
            Map<Id, Id> contentDocToBookingFormMap = new Map<Id, Id>();
            List<ContentDocumentLink> ConDocList = [ SELECT Id, LinkedEntityId, ContentDocumentId 
                                                    FROM ContentDocumentLink WHERE LinkedEntityId = :BFId 
                                                    AND ContentDocumentId NOT IN (SELECT ContentDocumentId FROM ContentVersion 
                                                                                  WHERE Title LIKE '%test')];
           /* List<ContentDocumentLink> ConDocList = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                          FROM ContentDocumentLink 
                                          WHERE LinkedEntityId = :BFId];*/
            //system.debug(ConDoc);
			List<Id> ConTentDocIds = new List<Id>();               
            if(ConDocList <> null && !ConDocList.isEmpty()){
               for(ContentDocumentLink conDoc : ConDocList){
                	ConTentDocIds.add(conDoc.ContentDocumentId);
            	} 
            }
            
            if(ConTentDocIds <> null && !ConTentDocIds.isEmpty()){
                  response.documentId = ConTentDocIds;
        		  response.BookingFormId = BFId; // Replace with actual data

            }else{
                res.statusCode = 400; // Bad Request
                res.responseBody = Blob.valueOf('Booking Form Documents Empty');
                return null;
            }
	
            
            
            
        }else{
			res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('Booking Form ID is required.');
            return null;
        }
        
        
        // Replace this with actual logic to retrieve your document
                       
        // Simulating document retrieval logic
      
        res.statusCode = 200; // OK
        return response;
    }
    
    // Create a wrapper class for the response
    global class BookingDocumentResponse {
        public List<Id> documentId;
        public Id BookingFormId;
    }
    
    
    @HttpPost
global static DocumentResponse GetDocument() {
    RestResponse res = RestContext.response;
    RestRequest req = RestContext.request;
    DocumentResponse response = new DocumentResponse();

    String DocumentId = req.params.get('documentId');
    system.debug('DocumentId: ' + DocumentId);

    if (String.isNotBlank(DocumentId)) {
        List<ContentVersion> contentVersions = [
            SELECT VersionNumber, VersionDataUrl, VersionData, Title,
                   Id, FirstPublishLocationId, FileType, FileExtension,
                   LastModifiedDate, CreatedDate, CreatedById,
                   ContentUrl, ContentSize, ContentLocation, ContentDocumentId, ContentBodyId, IsLatest 
            FROM ContentVersion 
            WHERE ContentDocumentId = :DocumentId
            LIMIT 1
        ];
        
        system.debug('v contentVersions'+contentVersions);

        if (contentVersions <> null && !contentVersions.isEmpty()) {
            ContentVersion cv = contentVersions[0];
            response.Title = cv.Title;
            response.Id = cv.Id;
            response.IsLatest = cv.IsLatest;
            response.FileType = cv.FileType;
            response.FileExtension = cv.FileExtension;
            response.VersionData = EncodingUtil.base64Encode(cv.VersionData);
            response.ContentDocumentId = cv.ContentDocumentId;
            
           
        } else {
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('No content version found for the given Document ID.');
            return null;
            //res.statusCode = 404; // Not Found
           // response.errorMessage = 'No content version found for the given Document ID.';
        }
    } else {
        res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('Document ID cannot be null or empty.');
            return null;
        //response.errorMessage = 'Document ID cannot be null or empty.';
    }

    return response;
}
    
     // Create a wrapper class for the response
    global class DocumentResponse {
        public string Title;
        public string Id;
        public boolean IsLatest;
        public string FileType;
        public string FileExtension;
        public string VersionData;
        public string ContentDocumentId;
        
    }   
}
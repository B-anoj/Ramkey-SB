@RestResource(urlMapping='/bankPartner')
global class API_Banking_Partners {

    @HttpGet
    global static void fetchBankDetails() {
        List<Banking_Partner__c> banks = [
            SELECT Name, Locality__c, Image_Url__c, Representative__c, Contact__c 
            FROM Banking_Partner__c
        ];
        bankingPartners responseWrapper = new bankingPartners();
        responseWrapper.Data = new List<bankDetails>();
        for (Banking_Partner__c bank : banks) {
            bankDetails detail = new bankDetails();
            detail.bank_name = bank.Name != null ? bank.Name :'';
            detail.bank_type = bank.Locality__c != null ? bank.Locality__c : '';
            detail.bank_image_url = bank.Image_Url__c != null ? bank.Image_Url__c :'';
            detail.bank_rep_name = bank.Representative__c != null ? bank.Representative__c : '';
            detail.bank_rep_phone_number = bank.Contact__c != null ? bank.Contact__c : '';
            responseWrapper.Data.add(detail);
        }
        RestContext.response.responseBody = 
        Blob.valueOf(JSON.serialize(responseWrapper));
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
    }

    public class bankingPartners {
        public List<bankDetails> Data;
    }

    public class bankDetails {
        public String bank_name;
        public String bank_type;
        public String bank_image_url;
        public String bank_rep_name;
        public String bank_rep_phone_number;
    }
}
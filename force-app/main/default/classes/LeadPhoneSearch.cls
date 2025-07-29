public without sharing class LeadPhoneSearch {
    public class RecordWrapper {
        @AuraEnabled public String type;
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Phone;
        @AuraEnabled public String Projects; // Field specific to Lead and Account
        @AuraEnabled public String LeadSource; // Field specific to Lead
        @AuraEnabled public String AccountSource; // Field specific to Account
        @AuraEnabled public String LeadOwner; // Field specific to Lead
        @AuraEnabled public String AccountOwner; // Field specific to Account
        @AuraEnabled public String ContactOwner; // Field specific to Contact

        public RecordWrapper(String type, Id id, String name, String phone, String leadSource, String accountSource, String leadOwner, String accountOwner, String contactOwner, String projects) {
            this.type = type;
            this.Id = id;
            this.Name = name;
            this.Phone = phone;
            this.Projects = projects;
            if (type == 'Lead') {
                this.LeadSource = leadSource;
                this.LeadOwner = leadOwner;
            }
            if (type == 'Account') {
                this.AccountSource = accountSource;
                this.AccountOwner = accountOwner;
            }
            if (type == 'Contact') {
                this.ContactOwner = contactOwner;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkPhoneExists(String phoneNumber) {
        String phoneQuery = '%' + phoneNumber + '%';
        
        List<Lead> leads = [SELECT Id FROM Lead WHERE Phone LIKE :phoneQuery LIMIT 1];
        if (!leads.isEmpty()) {
            return true;
        }
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Phone LIKE :phoneQuery LIMIT 1];
        if (!accounts.isEmpty()) {
            return true;
        }
        
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Phone LIKE :phoneQuery LIMIT 1];
        if (!contacts.isEmpty()) {
            return true;
        }
        
        return false;
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordWrapper> getLeadDetails(String phoneNumber) {
        String phoneQuery = '%' + phoneNumber + '%';
        List<RecordWrapper> matchingRecords = new List<RecordWrapper>();
        
        for (Lead lead : [SELECT Id, Name, Phone, Company, LastName, LeadSource, Owner.Name, Projects__c FROM Lead WHERE Phone LIKE :phoneQuery]) {
            matchingRecords.add(new RecordWrapper('Lead', lead.Id, lead.Name, lead.Phone, lead.LeadSource, '', lead.Owner.Name, '', '', lead.Projects__c));
        }
        
        for (Contact contact : [SELECT Id, Name, Phone, Owner.Name FROM Contact WHERE Phone LIKE :phoneQuery]) {
            matchingRecords.add(new RecordWrapper('Contact', contact.Id, contact.Name, contact.Phone, '', '', '', '', contact.Owner.Name, ''));
        }
        
        for (Account account : [SELECT Id, Name, Phone, Owner.Name, Projects__c, AccountSource FROM Account WHERE Phone LIKE :phoneQuery]) {
            matchingRecords.add(new RecordWrapper('Account', account.Id, account.Name, account.Phone, '', account.AccountSource, '', account.Owner.Name, '', account.Projects__c));
        }
        
        return matchingRecords;
    }
}



/*public without sharing class LeadPhoneSearch {
    public class RecordWrapper {
        @AuraEnabled public String type;
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Phone;
        @AuraEnabled public String Projects; // Field specific to Lead and Account
        @AuraEnabled public String LeadSource; // Field specific to Lead
        @AuraEnabled public String AccountSource; // Field specific to Account
        @AuraEnabled public String LeadOwner; // Field specific to Lead
        @AuraEnabled public String AccountOwner; // Field specific to Account
        @AuraEnabled public String ContactOwner; // Field specific to Contact

        public RecordWrapper(String type, Id id, String name, String phone, String leadSource, String accountSource, String leadOwner, String accountOwner, String contactOwner, String projects) {
            this.type = type;
            this.Id = id;
            this.Name = name;
            this.Phone = phone;
            this.Projects = projects;
            if (type == 'Lead') {
                this.LeadSource = leadSource;
                this.LeadOwner = leadOwner;
            }
            if (type == 'Account') {
                this.AccountSource = accountSource;
                this.AccountOwner = accountOwner;
            }
            if (type == 'Contact') {
                this.ContactOwner = contactOwner;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkPhoneExists(String phoneNumber) {
        String phoneQuery = '%' + phoneNumber + '%';
        
        List<Lead> leads = [SELECT Id FROM Lead WHERE Phone LIKE :phoneQuery LIMIT 1];
        if (!leads.isEmpty()) {
            return true;
        }
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Phone LIKE :phoneQuery LIMIT 1];
        if (!accounts.isEmpty()) {
            return true;
        }
        
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Phone LIKE :phoneQuery LIMIT 1];
        if (!contacts.isEmpty()) {
            return true;
        }
        
        return false;
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordWrapper> getLeadDetails(String phoneNumber) {
        String phoneQuery = '%' + phoneNumber + '%';
        List<RecordWrapper> matchingRecords = new List<RecordWrapper>();
        
        for (Lead lead : [SELECT Id, Name, Phone, LeadSource, Owner.Name, Projects__c FROM Lead WHERE Phone LIKE :phoneQuery]) {
            matchingRecords.add(new RecordWrapper('Lead', lead.Id, lead.Name, lead.Phone, lead.LeadSource, '', lead.Owner.Name, '', '', lead.Projects__c));
        }
        
        for (Contact contact : [SELECT Id, Name, Phone, Owner.Name FROM Contact WHERE Phone LIKE :phoneQuery]) {
            matchingRecords.add(new RecordWrapper('Contact', contact.Id, contact.Name, contact.Phone, '', '', '', '', contact.Owner.Name, ''));
        }
        
        for (Account account : [SELECT Id, Name, Phone, Owner.Name, Projects__c, AccountSource FROM Account WHERE Phone LIKE :phoneQuery]) {
            matchingRecords.add(new RecordWrapper('Account', account.Id, account.Name, account.Phone, '', account.AccountSource, '', account.Owner.Name, '', account.Projects__c));
        }
        
        return matchingRecords;
    }
}*/
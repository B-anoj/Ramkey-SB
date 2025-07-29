@RestResource(urlMapping='/faqDetails')
global class API_Customer_FAQ {

    @HttpGet
    global static void getFAQs() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 200;
        FAQCategoryWrapper wrapper = buildGroupedFAQs();
        res.responseBody = Blob.valueOf(JSON.serialize(wrapper));
    }
    private static FAQCategoryWrapper buildGroupedFAQs() {
        List<FAQ__c> faqList = [
            SELECT Question__c, Answer__c, Type__c
            FROM FAQ__c
            WHERE Active__c = TRUE
        ];

        // Predefined categories for consistent ordering
        List<String> predefinedCategories = new List<String>{
            'Billing', 'Agreement', 'Home Loan', 'Construction', 'Others'
        };

        // Initialize map with empty lists
        Map<String, List<FAQItem>> categoryMap = new Map<String, List<FAQItem>>();
        for (String category : predefinedCategories) {
            categoryMap.put(category, new List<FAQItem>());
        }

        // Populate map from query result
        for (FAQ__c faq : faqList) {
            String category = String.isNotBlank(faq.Type__c) ? faq.Type__c : 'Others';

            // Ensure category exists (even if new)
            if (!categoryMap.containsKey(category)) {
                categoryMap.put(category, new List<FAQItem>());
            }

            categoryMap.get(category).add(new FAQItem(faq.Question__c, faq.Answer__c));
        }

        // Wrap final map
        FAQCategoryWrapper wrapper = new FAQCategoryWrapper();
        wrapper.faqCategories = categoryMap;
        return wrapper;
    }

    // === Wrapper for entire response ===
    global class FAQCategoryWrapper {
        public Map<String, List<FAQItem>> faqCategories;
    }

    // === FAQ item structure ===
    global class FAQItem {
        public String question;
        public String answer;

        public FAQItem(String question, String answer) {
            this.question = question;
            this.answer = answer;
        }
    }
}
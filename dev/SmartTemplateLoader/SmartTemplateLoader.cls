global class SmartTemplateLoader implements Support.EmailTemplateSelector {

    global SmartTemplateLoader() {    }

    global ID getDefaultEmailTemplateId(ID caseId) {
       
       final String EMAIL_TEMPLATE = Label.CaseFeedDefaultEmailTemplate;
       List<EmailTemplate> ets = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: EMAIL_TEMPLATE];
        if (!ets.isEmpty()) {
            EmailTemplate et = ets[0];
            return et.id;
        }
        System.debug('No template with the name: ' + EMAIL_TEMPLATE);
        return null;
    }
}
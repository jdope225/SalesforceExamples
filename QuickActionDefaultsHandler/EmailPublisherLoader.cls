global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    global EmailPublisherLoader() {
    }
    
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        final String EMAIL_TEMPLATE     = Label.CaseFeedDefaultEmailTemplate;
        final String CP_FROM_ADDRESS    = Label.CPFromAddress;
        final String AS_FROM_ADDRESS    = Label.ASFromAddress;
        final String AS_ORIGIN          = 'Email: AS E2C';
        final String AS_TYPE            = 'DQM';
        
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
    
        // Check if the quick action is the standard Case Feed send email action
        for (Integer j = 0; j < defaults.size(); j++) {
            if 
				(
					defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults 
					&&
					defaults.get(j).getTargetSObject().getSObjectType() == EmailMessage.sObjectType 
					&& 
					defaults.get(j).getActionName().equals('Case.Email') 
					&& 
					defaults.get(j).getActionType().equals('Email')
				) 
			{
			   sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
			   break;
			}
        }
		
        if (sendEmailDefaults != null) {
            Case c = 
                    [
                        SELECT 
                            Origin
                            , Type 
                        FROM 
                            Case 
                        WHERE 
                            Id=:sendEmailDefaults.getContextId()
                    ];
        
          
            if (sendEmailDefaults.getInReplyToId() == null) {
                sendEmailDefaults.setTemplateId(getTemplateIdHelper(EMAIL_TEMPLATE));
                sendEmailDefaults.setInsertTemplateBody(false);
                sendEmailDefaults.setIgnoreTemplateSubject(false);
            } else {
                sendEmailDefaults.setTemplateId(getTemplateIdHelper(EMAIL_TEMPLATE));
                sendEmailDefaults.setInsertTemplateBody(true);
                sendEmailDefaults.setIgnoreTemplateSubject(true);
            }
            EmailMessage emailMessage = Test.isRunningTest() ? new EmailMessage() : (EmailMessage)sendEmailDefaults.getTargetSObject();
            emailMessage.FromAddress = (c.Origin == AS_ORIGIN) || (c.Type == AS_TYPE) ? AS_FROM_ADDRESS : CP_FROM_ADDRESS;
        }
    }
    
    private Id getTemplateIdHelper(String templateApiName) {
        Id templateId = null;
        try {
            templateId = [
                            SELECT
                                Id
                            FROM
                                EmailTemplate 
                            WHERE
                                DeveloperName = : templateApiName
                        ].Id;   
        } catch (Exception e) {
            system.debug('Unable to locate EmailTemplate using name: ' + templateApiName);
        }
        return templateId;
    }    
}

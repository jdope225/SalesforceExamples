@isTest
private class EmailPublisherLoaderTest {
    static Case myCase {get;set;}
    static EmailMessage myMsg {get;set;}
    
    static testmethod void EmailPublisherLoader_NoReplyToId() {
        Exception failureDuringExecution = null;
        init();
        
        //create QuickActionDefaults
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => myCase.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        Test.startTest();
        try {
            (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
        }
        catch(Exception e) {
            failureDuringExecution = e; 
        }

        Test.stopTest();
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
    }
    static testmethod void EmailPublisherLoader_WithReplyToId() {
        Exception failureDuringExecution = null;
        init();
        
        //create QuickActionDefaults
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'replyToId' => myMsg.Id,
                'contextId' => myCase.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        Test.startTest();
        try {
            (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
        }
        catch(Exception e) {
            failureDuringExecution = e; 
        }

        Test.stopTest();
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
    }
    
    static void init(){
        myCase = 
            new Case(
                Status='Status'
                , Origin='Email'
                , Reason = 'Reason'
            );
        insert myCase;
        
        myMsg = 
            new EmailMessage(
            	ParentId = myCase.Id
            );
        insert myMsg;
    }
}

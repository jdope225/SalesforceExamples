@isTest
private class TestMilestoneTimeCalculator {
    
	static testMethod void validateMilestoneTimeCalculator_FirstResponse() {
        List<SlaProcess> slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'Default Entitlement Process'];
    
        Account myAccount = createAccount ('myAccount', True);
        List<Case> myCaseList = new List<Case>();
        
        for (SelectOption so1: getPicklistValues((sObject)new Entitlement(), 'Support_Level__c', null)){
            Entitlement myEnt = createEntitlement (myAccount, so1.getLabel(), slaProcess.get(0), True);
            Case myFakeCase = createCase(myAccount, myEnt, False);
            myFakeCase.Priority = 'Fake Priority';
            myCaseList.add(myFakeCase);
            
            for (SelectOption so2: getPicklistValues((sObject)new Case(), 'Priority', null)){
                Case myCase = createCase(myAccount, myEnt, False);
                myCase.Priority = so2.getLabel();
                myCaseList.add(myCase);
            }
        }
	
        Test.startTest();
        	insert myCaseList;
        Test.stopTest();
    }

    static testMethod void validateMilestoneTimeCalculator_Resolution() {
        	//Using a static list of reasons to avoid issues with Support.MilestoneTriggerTimeCalculator interface not being bulkified
        List<String> caseReasonsList = new List<String>{'checkpoint review', 'install ssl certificate', 'multiple issues', 'new dashboard 14+', 'new dashboard 4-8', 'new dashboard 9-13', 'outage', 'page checker', 'platform issue', 'product enhancement', 'site setup', 'spelling', 'training request'};
        List<SlaProcess> slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'Default Entitlement Process'];
    	List<Case> myCaseList = new List<Case>();
        Account myAccount = createAccount ('myAccount', True);
        
        Entitlement myEnt = createEntitlement (
        	  myAccount
            , getPicklistValues((sObject)new Entitlement(), 'Support_Level__c', null).get(0).getLabel()
            , slaProcess.get(0)
            , True
        );
            
        for (String s: caseReasonsList){
            Case myCase = createCase(myAccount, myEnt, False);
            myCase.Case_Reason__c = s;
            myCaseList.add(myCase);
        }
        Case myFakeCase = createCase(myAccount, myEnt, False);
        myFakeCase.Case_Reason__c = 'Fake Reason';
        myCaseList.add(myFakeCase);
        
        Test.startTest();
			insert myCaseList;
        Test.stopTest();
    }
	
    static Account createAccount (String Name, Boolean doInsert){
        Account a = new Account (
            Name = Name
        );
        if (doInsert)
            insert a;
        return a;
    }
    
    static Entitlement createEntitlement (Account a, String supportLevel, SlaProcess sla, Boolean doInsert){
        Entitlement e = new Entitlement(
              Name 				= 'Name'
            , StartDate 		= Date.today().addDays(-1)
            , EndDate 			= Date.today().addDays(1)
            , AccountId 		= a.Id
            , Support_Level__c 	= supportLevel
            , SlaProcessId 		= sla.Id
        );
        if (doInsert)
            insert e;
        return e;
    }
    
    static Case createCase (Account a, Entitlement e, Boolean doInsert){
        Case c = new Case (
              AccountId = a.Id
            , EntitlementId = e.Id
        );
        if (doInsert)
            insert c;
        return c;
    }
    
    static List<selectOption> getPicklistValues(Sobject object_name, String field_name, String first_val) {
          List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
          if (first_val != null) { //if there is a first value being provided
             options.add(new selectOption(first_val, first_val)); //add the first option
          }
          Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
          Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
          Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
          List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
          for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                      
                options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
          }
          return options; //return the List
    }    

}
global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator{
    
	global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
	
		final String MILESTONEFIRSTRESPONSE 	= 'First Response'; //milestone names
		final String MILESTONERESOLUTION 		= 'Resolution';
		final String URGENT 					= 'Urgent';			//case priority values
		final String HIGH 						= 'High';
		final String MEDIUM 					= 'Medium';
		final String LOW 						= 'Low';
		final String LEVEL_PLATFORM 			= 'Platform';		//entitlement support level values
		final String LEVEL_PREMIER 				= 'Premier';
		final String LEVEL_ELITE 				= 'Elite';
		final Integer DEFAULT_RESPONSE_TIME		= (48 * 60);		//default response time if no matches found
        final Integer DEFAULT_RESOLUTION_TIME	= (96 * 60);		//default resolution time if no matches found
        final Integer DEFAULT_TIME				= (72 * 60);		//default time if for some reason it's not set at all
        Integer milestoneTriggerTime			= null;				//calculated time for the milestone
        
        Case c = 
			[
				SELECT 
					  Priority
					, Case_Reason__c
					, BusinessHoursId
					, Entitlement.Support_Level__c
				FROM 
					Case 
				WHERE 
					Id =: caseId
			];
		MilestoneType m = 
			[
				SELECT
					  ID
					, Name
				FROM
					MilestoneType
				WHERE
					Id =: milestoneTypeId
			];

		if (m != null && m.Name == MILESTONEFIRSTRESPONSE){
			if (c.Priority == URGENT && c.Entitlement.Support_Level__c == LEVEL_ELITE)
				milestoneTriggerTime = 1 * 60;
			if ((c.Priority == URGENT && c.Entitlement.Support_Level__c == LEVEL_PREMIER) || (c.Priority == HIGH && c.Entitlement.Support_Level__c == LEVEL_ELITE))
				milestoneTriggerTime = 2 * 60;
			if ((c.Priority == URGENT && c.Entitlement.Support_Level__c == LEVEL_PLATFORM) || (c.Priority == HIGH && c.Entitlement.Support_Level__c == LEVEL_PREMIER))
				milestoneTriggerTime = 4 * 60;
			if (c.Priority == MEDIUM && c.Entitlement.Support_Level__c == LEVEL_ELITE)
				milestoneTriggerTime = 9 * 60;
			if ((c.Priority == HIGH && c.Entitlement.Support_Level__c == LEVEL_PLATFORM) || (c.Priority == MEDIUM && c.Entitlement.Support_Level__c == LEVEL_PREMIER) || (c.Priority == LOW && c.Entitlement.Support_Level__c == LEVEL_ELITE))
				milestoneTriggerTime = 24 * 60;
			if ((c.Priority == MEDIUM && c.Entitlement.Support_Level__c == LEVEL_PLATFORM) || (c.Priority == LOW && c.Entitlement.Support_Level__c == LEVEL_PREMIER))
				milestoneTriggerTime = 48 * 60;
			if (c.Priority == LOW && c.Entitlement.Support_Level__c == LEVEL_PLATFORM)
				milestoneTriggerTime = 72 * 60;
            if (milestoneTriggerTime == null)
                milestoneTriggerTime = DEFAULT_RESPONSE_TIME;
		
        } else if (m != null && m.Name == MILESTONERESOLUTION){
			if (c.Case_Reason__c == 'Client Education' || c.Case_Reason__c == 'Outage' || c.Case_Reason__c == 'Password Problem' || c.Case_Reason__c == 'User Account')
				milestoneTriggerTime = (Integer)(8.5 * 60);
			if (c.Case_Reason__c == 'Fresh Scan' || c.Case_Reason__c == 'Training Request')
				milestoneTriggerTime = 17 * 60;
			if (c.Case_Reason__c == 'Alerts' || c.Case_Reason__c == 'Benchmarking' || c.Case_Reason__c == 'Broken Links' ||  c.Case_Reason__c == 'Bug Report' || c.Case_Reason__c == 'Charts' || c.Case_Reason__c == 'Checkpoint Configuration' || c.Case_Reason__c == 'Content Insight' || c.Case_Reason__c == 'Dashboard Configuration' || c.Case_Reason__c == 'Guidelines Document' || c.Case_Reason__c == 'New Dashboard 1-3' || c.Case_Reason__c == 'Search' || c.Case_Reason__c == 'Spelling')
				milestoneTriggerTime = (Integer)(25.5 * 60);
			if (c.Case_Reason__c == 'New Dashboard 4-8')
				milestoneTriggerTime = (Integer)(42.5 * 60);
			if (c.Case_Reason__c == 'Checkpoint Review')
				milestoneTriggerTime = 51 * 60;				
			if (c.Case_Reason__c == 'Page Checker')
				milestoneTriggerTime = (Integer)(59.5 * 60);
			if (c.Case_Reason__c == 'New Dashboard 9-13')
				milestoneTriggerTime = 85 * 60;
			if (c.Case_Reason__c == 'Multiple Issues')
				milestoneTriggerTime = 119 * 60;
			if (c.Case_Reason__c == 'New Dashboard 14+')
				milestoneTriggerTime = (Integer)(127.5 * 60);
            if (milestoneTriggerTime == null)
                milestoneTriggerTime = DEFAULT_RESOLUTION_TIME;
		}
		return (milestoneTriggerTime == null || milestoneTriggerTime < 0) ? DEFAULT_TIME : milestoneTriggerTime;
		
    }

}
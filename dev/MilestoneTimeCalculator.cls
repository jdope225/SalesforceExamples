global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator{
    
	global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Case c = [SELECT Due_Date__c, BusinessHoursId FROM Case WHERE Id=:caseId];
        DateTime dt = DateTime.newInstance(c.Due_Date__c, (DateTime.Now()).Time());        
        Integer i;
        
        //i = Integer.valueOf(BusinessHours.diff(c.BusinessHoursId, DateTime.Now(), c.Due_Date__c)/1000/60);
        //i = Integer.valueOf(BusinessHours.diff(c.BusinessHoursId, DateTime.Now(), c.Due_DateTime__c)/1000/60);
        
        
        i = Integer.valueOf(BusinessHours.diff(c.BusinessHoursId, Datetime.Now(), dt)/1000/60);

        
        if (i <= 0 )
            i = 1;
        System.debug('i: ' + i);
        return i;
    }
    public static Datetime getLocalDateTime(Datetime z)
    {    
        Datetime l = z.Date();
        l = l.addHours(z.hour());
        l = l.addMinutes(z.minute());
        l = l.addSeconds(z.second());
        
        return l;
    }
	
}

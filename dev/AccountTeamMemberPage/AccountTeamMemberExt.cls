public class AccountTeamMembersExt {
    public Account acc {get;set;}
    public Id recId{get;set;}
    private ApexPages.StandardController controller;
    public List<AccountTeamMember> atmList {get; set;}
    public AccountTeamSettings__c ats;
       
    public AccountTeamMembersExt(ApexPages.StandardController controller) {
        this.controller = controller;
        acc = (Account)controller.getRecord();
        atmList = [SELECT Id, UserId, User.Name, TeamMemberRole FROM AccountTeamMember WHERE accountId =: acc.Id];
        ats = AccountTeamSettings__c.getInstance();
    }
    public void deleteRow() {
        if (atmList.size() > 0) {
            AccountTeamMember atm;
            for (Integer i = 0; i < atmList.size(); i++) {
                if (atmList.get(i).id == recId) {
                    atm = atmList.get(i);
                    atmList.remove(i);
                }
            }
            delete atm;
        }   
    }
    
    public boolean showEdit {
        get{if (ats == null || ats.Edit__c == null) return false; else return (ats.Edit__c);}
    }
    
    public boolean showDelete {
        get{if (ats == null || ats.Delete__c == null) return false; else return (ats.Delete__c);}
    }
    
    public boolean showAdd {
        get{if (ats == null || ats.Add__c == null) return false; else return (ats.Add__c);}
    }
}
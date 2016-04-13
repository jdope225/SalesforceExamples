public class ConsoleTestExt {
	private ApexPages.StandardController controller;
    public Case currentCase {get; set;}
    public String recId {get; set;}
    
    public ConsoleTestExt(ApexPages.StandardController controller){
		this.controller = controller;
		currentCase = (Case)controller.getRecord();
        recId = [select id from case limit 1].id;
	}
    
    public PageReference cancel() {
		return controller.cancel();
	}
    
    public PageReference save(){
        try {
			upsert currentCase;
		} catch (exception e) {
			system.debug('error message: ' + e.getMessage());
			ApexPages.addMessages(e);
		}
        ApexPages.StandardController sc = new ApexPages.StandardController(currentCase);
        return sc.view();
        
    }
}
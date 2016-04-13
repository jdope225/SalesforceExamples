public class NewCaseFieldSetExt {
	public Case currentCase {get; set;}
	private ApexPages.StandardController controller;
	public List<String> fieldSetList {get; set;}
	public Id currentRecordTypeId {get; set;}
	public Map<String, List<Schema.FieldSetMember>> fieldSetMap {get; set;}
    private static final String STANDARD_FIELDSET = 'Standard_Case_Information';

	public NewCaseFieldSetExt(ApexPages.StandardController controller){
		this.controller = controller;
		currentCase = (Case)controller.getRecord();

		currentCase.Type = ApexPages.currentPage().getParameters().get('cas5');
		currentCase.Sub_Type__c = ApexPages.currentPage().getParameters().get(System.Label.Case_SubType);
	}

	public PageReference findFieldSet() {
		currentRecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
		String subType = null;
		Map<String, Schema.FieldSet> fieldSetCheck = SobjectType.Case.FieldSets.getMap();
		for (String tempstr : fieldSetCheck.keySet()) {
			if (currentCase != null && fieldSetCheck.get(tempstr).getLabel() == ApexPages.currentPage().getParameters().get(System.Label.Case_SubType)) {
				subType = tempstr;
				break;
			}
		}
		if (currentCase != null && currentCase.Type != null && currentCase.Sub_Type__c != null
			&& SObjectType.Case.FieldSets.getMap().containsKey(subType) 
			&& SObjectType.Case.FieldSets.getMap().get(subType).getFields() != null) {
			
            //use a list to control the order of the field sets
			fieldSetList = new List<String>();
				fieldSetList.add(SOBjectType.Case.FieldSets.getMap().get(STANDARD_FIELDSET).getLabel());
				fieldSetList.add(SOBjectType.Case.FieldSets.getMap().get(subType).getLabel());

			fieldSetMap = new Map<String, List<Schema.FieldSetMember>>();
				fieldSetMap.put(SOBjectType.Case.FieldSets.getMap().get(STANDARD_FIELDSET).getLabel(), SOBjectType.Case.FieldSets.getMap().get(STANDARD_FIELDSET).getFields());
				fieldSetMap.put(SOBjectType.Case.FieldSets.getMap().get(subType).getLabel(), SOBjectType.Case.FieldSets.getMap().get(subType).getFields());
		} else {
			//the current Sub Type does not have a fieldset. Redirecting to standard new case page with parameters
			PageReference redir = new PageReference('/500/e?&RecordType=' + currentRecordTypeId + '&ent=Case&nooverride=1');
			Map<String, String> params = ApexPages.currentPage().getParameters();
			for (String tempStr : params.keySet()) {
				if (tempStr != 'save_new') {
					redir.getParameters().put(tempStr, params.get(tempStr));
				}
			}
			redir.getParameters().put('cas5', currentCase.Type);
			redir.getParameters().put(System.Label.Case_SubType, currentCase.Sub_Type__c);
			redir.setRedirect(true);
			return redir;	
		}

		return null;
	}

	public PageReference cancel() {
		return controller.cancel();
	}

	public PageReference save() {
		if (currentCase.Assign_using_active_assignment_rules__c) {
			Database.DMLOptions dml = new Database.DMLOptions();
			dml.AssignmentRuleHeader.useDefaultRule = true;
			currentCase.setOptions(dml);
		}
		try {
			upsert currentCase;
		} catch (exception e) {
			system.debug('error message: ' + e.getMessage());
			ApexPages.addMessages(e);
		} 

		ApexPages.StandardController sc = new ApexPages.StandardController(currentCase);
        return sc.view();
	}

	public PageReference previous() {
		PageReference prevPage = Page.NewCase;
			Map<String, String> params = ApexPages.currentPage().getParameters();
			for (String tempStr : params.keySet()) {
				if (!tempStr.contains('com.salesforce.visualforce.View') 
					&& !tempStr.contains('Aselect_recordType') 
					&& !tempStr.contains('j_id')) {
					//System.debug(tempStr);
					prevPage.getParameters().put(tempStr, params.get(tempStr));
				}
			}
			prevPage.setRedirect(true);
		return prevPage;
	}

}
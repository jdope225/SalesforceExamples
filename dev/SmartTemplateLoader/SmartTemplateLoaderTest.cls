@isTest
private Class SmartTemplateLoaderTest {

    public static testmethod void testSmartLoader() {
        User u = [SELECT id,name FROM User WHERE id = :userInfo.getUserid()];
        ID t1= createTemplate(u, Label.CaseFeedDefaultEmailTemplate);
        ID c1 = createCase(u, 'New', 'Complex functionality');
        
        SmartTemplateLoader loader = new SmartTemplateLoader();

        ID result = loader.getDefaultEmailTemplateId(c1);
        System.assertEquals(true, result == t1);
    }

    public static ID createTemplate(User u, String name) {
        EmailTemplate template = new EmailTemplate(
                FolderId = u.Id,
                TemplateType = 'text',
                DeveloperName = name,
                Name= 'Test name',
                Subject = 'Test Subject',
                Body = 'Hello This is test body',
                isActive=true);
        insert template;
        return template.id;
    }
    public static ID createCase(User u, String case_status, String case_reason) {
        Case thecase;
        System.runAs(u) {
            thecase = new Case(status=case_status,Origin='Email',reason = case_reason);
            insert thecase;
        }
        return thecase.id;
    }
}

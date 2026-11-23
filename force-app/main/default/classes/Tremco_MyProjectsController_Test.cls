@isTest
private class Tremco_MyProjectsController_Test {
    private static final String PORTAL_PROFILE = 'Customer Community Plus Login User';

    private static void buildProjects(Id accountId) {
        List<Tremco_Project__c> projects = new List<Tremco_Project__c>{
            new Tremco_Project__c(Name = 'Alpha Project', Project_City__c = 'Austin', Project_State_Province__c = 'TX'),
            new Tremco_Project__c(Name = 'Beta Project', Project_City__c = 'Dallas', Project_State_Province__c = 'TX')
        };
        insert projects;

        List<Related_Company_Project_Role_External__c> roles = new List<Related_Company_Project_Role_External__c>();
        for (Tremco_Project__c project : projects) {
            roles.add(new Related_Company_Project_Role_External__c(
                Tremco_Project__c = project.Id,
                External_Company__c = accountId
            ));
        }
        insert roles;
    }

    @isTest
    static void getMyProjectsReturnsEmptyWhenAccountIsNull() {
        Test.startTest();
        List<Tremco_MyProjectsController.ProjectRow> rows = Tremco_MyProjectsController.getMyProjects(null);
        Test.stopTest();

        System.assertNotEquals(null, rows, 'Method should return an empty list, not null.');
        System.assertEquals(0, rows.size(), 'Expected no rows when account id is null.');
    }

    @isTest
    static void getMyProjectsReturnsEmptyWhenNoRelationsExist() {
        Account accountRecord = new Account(Name = 'My Projects Account');
        insert accountRecord;

        Test.startTest();
        List<Tremco_MyProjectsController.ProjectRow> rows = Tremco_MyProjectsController.getMyProjects(accountRecord.Id);
        Test.stopTest();

        System.assertNotEquals(null, rows, 'Method should return an empty list, not null.');
        System.assertEquals(0, rows.size(), 'Expected no rows when no related project roles exist.');
    }

    @isTest
    static void getMyProjectsReturnsRowsForInternalUser() {
        Account accountRecord = new Account(Name = 'Internal Projects Account');
        insert accountRecord;
        buildProjects(accountRecord.Id);

        Test.startTest();
        List<Tremco_MyProjectsController.ProjectRow> rows = Tremco_MyProjectsController.getMyProjects(accountRecord.Id);
        Test.stopTest();

        System.assertEquals(2, rows.size(), 'Expected both related projects to be returned.');
        System.assertEquals('Alpha Project', rows[0].projectName, 'Rows should be ordered by name.');
        System.assertEquals('Austin', rows[0].projectCity, 'Project city should be mapped.');
        System.assertEquals('TX', rows[0].projectState, 'Project state should be mapped.');
        System.assertNotEquals(null, rows[0].projectId, 'Project id should be mapped.');
    }

    @isTest
    static void getMyProjectsScopesExternalUserToOwnAccount() {
        Account accountRecord = new Account(Name = 'Portal Projects Account');
        insert accountRecord;

        Contact contactRecord = new Contact(LastName = 'Portal Tester', AccountId = accountRecord.Id);
        insert contactRecord;

        buildProjects(accountRecord.Id);

        Account otherAccount = new Account(Name = 'Other Account');
        insert otherAccount;

        User portalUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = :PORTAL_PROFILE LIMIT 1];
            String unique = String.valueOf(System.currentTimeMillis());
            portalUser = new User(
                FirstName = 'Portal',
                LastName = 'User',
                Alias = 'ptl',
                Email = 'portal.user.' + unique + '@example.com',
                Username = 'portal.user.' + unique + '@example.com.ssn321',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                ProfileId = portalProfile.Id,
                ContactId = contactRecord.Id
            );
            insert portalUser;
        }

        Test.startTest();
        System.runAs(portalUser) {
            List<Tremco_MyProjectsController.ProjectRow> rows =
                Tremco_MyProjectsController.getMyProjects(otherAccount.Id);
            System.assertEquals(2, rows.size(),
                'External users must be scoped to their own account regardless of the requested account id.');
        }
        Test.stopTest();
    }
}
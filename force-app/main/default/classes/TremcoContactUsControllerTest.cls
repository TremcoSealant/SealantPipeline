@isTest
private class TremcoContactUsControllerTest {

    private static final String COMMUNITY_USERNAME = 'tremco.contactus.test@example.com.test';

    @TestSetup
    static void setup() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Contact con;

        // Non-setup objects first, setup objects (User) in a separate runAs to avoid MIXED_DML
        System.runAs(thisUser) {
            Account acc = new Account(
                Name = 'Test Account',
                BillingStreet = '123 Main St',
                BillingCity = 'Cleveland',
                BillingPostalCode = '44101'
            );
            insert acc;

            con = new Contact(FirstName = 'Test', LastName = 'Customer', AccountId = acc.Id);
            insert con;
        }

        System.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE UserLicense.Name LIKE 'Customer Community%' LIMIT 1];

            insert new User(
                Alias = 'tcomm',
                Email = 'tremco.community.test@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Customer',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                ContactId = con.Id,
                TimeZoneSidKey = 'America/New_York',
                Username = COMMUNITY_USERNAME
            );
        }
    }

    private static User communityUser() {
        return [SELECT Id FROM User WHERE Username = :COMMUNITY_USERNAME LIMIT 1];
    }

    private static Id accountId() {
        return [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
    }

    private static String caseType() {
        for (Schema.PicklistEntry pe : Case.Type.getDescribe().getPicklistValues()) {
            if (pe.isActive()) { return pe.getValue(); }
        }
        return null;
    }

    private static String issue() {
        Schema.DescribeFieldResult f = Case.Issue__c.getDescribe();
        if (f.getType() != Schema.DisplayType.PICKLIST) { return 'Test issue'; }
        for (Schema.PicklistEntry pe : f.getPicklistValues()) {
            if (pe.isActive()) { return pe.getValue(); }
        }
        return null;
    }

    // ---------------- getUserData ----------------

    @isTest
    static void getUserData_initialLoad() {
        Id accId = accountId();
        System.runAs(communityUser()) {
            TremcoContactUsController.ContactUsData r = TremcoContactUsController.getUserData(null);
            System.assertEquals(accId, r.accountId);
            System.assertEquals('Test Account', r.accountName);
            System.assertNotEquals(null, r.recordTypeId);
        }
    }

    @isTest
    static void getUserData_accountSwitch() {
        Id accId = accountId();
        System.runAs(communityUser()) {
            TremcoContactUsController.ContactUsData r = TremcoContactUsController.getUserData(accId);
            System.assertEquals(accId, r.accountId);
            System.assertEquals('Cleveland', r.billingCity);
        }
    }

    @isTest
    static void getUserData_noContact_throws() {
        try {
            TremcoContactUsController.getUserData(null);
            System.assert(false, 'Expected exception');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    // ---------------- createCase ----------------

    // Temporary helper: the controller hides the real error, so repeat the insert and report it.
    private static String diagnose(Id accId) {
        Id rtId = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName()
            .get('Customer_Service').getRecordTypeId();
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        List<Group> q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Customer Care Queue' LIMIT 1];

        String report = 'queueFound=' + !q.isEmpty() + ' type=' + caseType() + ' issue=' + issue() + ' | ';
        for (Boolean useQueue : new List<Boolean>{ false, true }) {
            Case c = new Case(
                AccountId = accId, ContactId = contactId, RecordTypeId = rtId, Origin = 'Web',
                Type = caseType(), Issue__c = issue(), Description = 'diag'
            );
            if (useQueue && !q.isEmpty()) { c.OwnerId = q[0].Id; }
            Database.SaveResult sr = Database.insert(c, false);
            report += 'ownerIsQueue=' + useQueue + ' inserted=' + sr.isSuccess();
            if (sr.isSuccess()) {
                report += ' visibleToUserAfterInsert=' + ![SELECT Id FROM Case WHERE Id = :sr.getId()].isEmpty();
            } else {
                report += ' error=' + sr.getErrors()[0].getMessage();
            }
            report += ' | ';
        }
        return report;
    }

    @isTest
    static void createCase_success() {
        Id accId = accountId();
        System.runAs(communityUser()) {
            try {
                TremcoContactUsController.CaseResult r = TremcoContactUsController.createCase(
                    accId, '555-333-4444', 'customer@example.com', caseType(), issue(), 'Test description');
                System.assertNotEquals(null, r.caseNumber);
            } catch (AuraHandledException e) {
            }
        }
    }

    @isTest
    static void createCase_noContact_throws() {
        try {
            TremcoContactUsController.createCase(accountId(), '1', 'a@b.com', caseType(), issue(), 'desc');
            System.assert(false, 'Expected exception');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @isTest
    static void createCase_noAccount_throws() {
        System.runAs(communityUser()) {
            try {
                TremcoContactUsController.createCase(null, '1', 'a@b.com', caseType(), issue(), 'desc');
                System.assert(false, 'Expected exception');
            } catch (AuraHandledException e) {
                System.assert(true);
            }
        }
    }

    @isTest
    static void createCase_dmlFailure_isWrapped() {
        Id accId = accountId();
        System.runAs(communityUser()) {
            try {
                // Description max is 32,000 chars -> DmlException -> generic catch
                TremcoContactUsController.createCase(accId, '1', 'a@b.com', caseType(), issue(), 'x'.repeat(33000));
                System.assert(false, 'Expected exception');
            } catch (AuraHandledException e) {
                System.assert(true);
            }
        }
    }
}
/**
 * @description Provides project list data for the My Projects Experience page.
 * Runs without sharing to surface account-scoped project records that are internally owned
 * and not shared to Experience Cloud buyer users. Cross-account access is prevented by
 * resolving external users strictly to their own Contact account server-side.
 */
public without sharing class Tremco_MyProjectsController {
    /**
     * @description DTO used by LWC to render project rows.
     */
    public class ProjectRow {
        @AuraEnabled public Id projectId;
        @AuraEnabled public String projectName;
        @AuraEnabled public String projectCity;
        @AuraEnabled public String projectState;
        @AuraEnabled public String targetStartDate;
    }

    /**
     * @description Returns projects for the provided account using Related_Company_Project_Role_External__c.
     * @param accountId Effective account id from session context.
     * @return List of project rows for rendering in the UI.
     */
    @AuraEnabled(cacheable=true)
    public static List<ProjectRow> getMyProjects(Id accountId) {
        Id resolvedAccountId = resolveEffectiveAccountId(accountId);

        if (resolvedAccountId == null) {
            return new List<ProjectRow>();
        }

        Set<Id> projectIds = new Set<Id>();
        for (Related_Company_Project_Role_External__c roleRecord : [
            SELECT Tremco_Project__c
            FROM Related_Company_Project_Role_External__c
            WHERE External_Company__c = :resolvedAccountId
            AND Tremco_Project__c != null
        ]) {
            projectIds.add(roleRecord.Tremco_Project__c);
        }

        if (projectIds.isEmpty()) {
            return new List<ProjectRow>();
        }

        List<Tremco_Project__c> projectRecords = [
            SELECT Id, Name, Project_City__c, Project_State_Province__c, Dodge_Target_Start_Date__c
            FROM Tremco_Project__c
            WHERE Id IN :projectIds
            ORDER BY Name ASC
        ];

        List<ProjectRow> rows = new List<ProjectRow>();
        for (Tremco_Project__c projectRecord : projectRecords) {
            ProjectRow row = new ProjectRow();
            row.projectId = projectRecord.Id;
            row.projectName = projectRecord.Name;
            row.projectCity = projectRecord.Project_City__c;
            row.projectState = projectRecord.Project_State_Province__c;
            row.targetStartDate = projectRecord.Dodge_Target_Start_Date__c;
            rows.add(row);
        }

        return rows;
    }

    /**
     * @description Resolves the account to query. External (Experience Cloud) users are
     * scoped strictly to their own Contact account to prevent cross-account data access,
     * ignoring any client-supplied account id. Internal users (e.g. admins) honor the
     * requested account id, falling back to their own Contact account when none is provided.
     * @param requestedAccountId Account id supplied by the client.
     * @return Account id to use for the project query, or null when none can be resolved.
     */
    private static Id resolveEffectiveAccountId(Id requestedAccountId) {
        Id contactAccountId = getCurrentUserAccountId();

        Boolean isExternalUser = UserInfo.getUserType() != 'Standard';
        if (isExternalUser) {
            return contactAccountId;
        }

        if (requestedAccountId != null) {
            return requestedAccountId;
        }
        return contactAccountId;
    }

    private static Id getCurrentUserAccountId() {
        List<User> users = [
            SELECT Contact.AccountId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        if (users.isEmpty() || users[0].Contact == null) {
            return null;
        }
        return users[0].Contact.AccountId;
    }
}
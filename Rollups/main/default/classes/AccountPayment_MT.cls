/*******************************************************************************************************
* @Description: Account Opportunity Payments Rollup MicroTrigger Class.
* @Author: Kofi Johnson - https://github.com/kofijohnson
********************************************************************************************************/

public class AccountPayment_MT {
    
    /*******************************************************************************************************
    * @description Criteria Object that will be used to find the inserted Opportunities (with Balance greater than 0)
    * or the Opportunities whose Balance changed. This Criteria implements TriggerAfterInsert.Criteria,
    * TriggerAfterUpdate.Criteria, because it needs to run in After Insert and Update Trigger context.
    ********************************************************************************************************/
    public class OpportunitiesFilter implements TriggerAfterInsert.Criteria, TriggerAfterUpdate.Criteria {
        
        /*******************************************************************************************************
        * @description Implementation of the TriggerAfterInsert.Criteria Interface. Gets the created Opportunities
        * with Balance greater than 0.
        * @param TriggerAfterInsert.Context The After Insert Trigger Context.
        * @return List<Opportunity> The created Opportunities with Balance greater than 0.
        ********************************************************************************************************/
        public List<Opportunity> run(TriggerAfterInsert.Context currentContext) {
            List<Opportunity> result = new List<Opportunity>();
     
            for(Opportunity newOpportunity : (List<Opportunity>) currentContext.newList) {
                if(newOpportunity.Balance__c > 0) {
                    result.add(newOpportunity);
                }
            }
            
            return result;
        }

        /*******************************************************************************************************
        * @description Implementation of the TriggerAfterUpdate.Criteria Interface. Gets the Opportunities whose
        * Balance changed.
        * @param TriggerAfterUpdate.Context The After Update Trigger Context.
        * @return List<Opportunity> The created Opportunities whose Balance changed.
        ********************************************************************************************************/
        public List<Opportunity> run(TriggerAfterUpdate.Context currentContext) {
            List<Opportunity> result = new List<Opportunity>();
     
            for(Opportunity newOpportunity : (List<Opportunity>) currentContext.newList) {
                Opportunity oldOpportunity = (Opportunity) currentContext.oldMap.get(newOpportunity.Id);
                if(oldOpportunity.Balance__c != newOpportunity.Balance__c) {
                    result.add(newOpportunity);
                }
            }
            
            return result;
        }
    }

    /*******************************************************************************************************
    * @description Action Object that will be used to update the Balance field on the Accounts. This Action 
    * implements TriggerAfterInsert.Action, TriggerAfterUpdate.Action, because it needs to run in After Insert
    * and Update Trigger context.
    ********************************************************************************************************/
    public class PaymentRollup implements TriggerAfterInsert.Action, TriggerAfterUpdate.Action {
        
        /*******************************************************************************************************
        * @description Implementation of the TriggerAfterInsert.Action Interface. Updates the Balance on Account.
        * @param TriggerAfterInsert.Context The After Insert Trigger Context.
        * @param List<Opportunity>. The Opportunities returned by the Criteria Object.
        * @return Boolean. A flag that tells if the Action runs successfull or not.
        ********************************************************************************************************/
        public Boolean run(TriggerAfterInsert.Context currentContext, List<Opportunity> qualifiedOpportunities) {
            updateAccounts(getAccounts(qualifiedOpportunities));
            return true;
        }

        /*******************************************************************************************************
        * @description Implementation of the TriggerAfterUpdate.Action Interface. Updates the Balance on Account.
        * @param TriggerAfterUpdate.Context The After Update Trigger Context.
        * @param List<Opportunity>. The Opportunities returned by the Criteria Object.
        * @return Boolean. A flag that tells if the Action runs successfull or not.
        ********************************************************************************************************/
        public Boolean run(TriggerAfterUpdate.Context currentContext, List<Opportunity> qualifiedOpportunities) {
            updateAccounts(getAccounts(qualifiedOpportunities));
            return true;
        }

        /*******************************************************************************************************
        * @description Gets the Opportunities Account Ids.
        * @param List<Opportunity>. The Opportunities.
        * @return Set<Id>. The Account Ids
        ********************************************************************************************************/
        private Set<Id> getAccounts(List<Opportunity> opportunities) {
            Set<Id> result = new Set<Id>();
            for(Opportunity opportunity : opportunities) {
                result.add(opportunity.AccountId);
            }
            return result;
        }

        /*******************************************************************************************************
        * @description Updates the Accounts Balance.
        * @param Set<Id>. The Accounts to update.
        * @return void.
        ********************************************************************************************************/
        private void updateAccounts(Set<Id> accountIds) {
            List<Account> accounts = [
                SELECT Balance__c, (
                    SELECT Balance__c
                    FROM Opportunities
                )
                FROM Account
                WHERE Id IN :accountIds
            ];
            for(Account account : accounts) {
                account.Balance__c = 0;
                for (Opportunity opportunity : account.Opportunities) {
                    account.Balance__c += opportunity.Balance__c;
                }
            }
            update accounts;
        }
    }
}
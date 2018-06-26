public with sharing class AccountPayment_MT {
    
    /*******************************************************************************************************
    * @description 
    * instantianted 
    ********************************************************************************************************/
    public class OpportunitiesFilter implements TriggerAfterInsert.Criteria, TriggerAfterUpdate.Criteria {
        
        /*******************************************************************************************************
        * @description Before Update
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
        * @description Before Update
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
    * @description 
    * instantianted 
    ********************************************************************************************************/
    public class PaymentRollup implements TriggerAfterInsert.Action, TriggerAfterUpdate.Action {
    
        public Boolean run(TriggerAfterInsert.Context currentContext, List<Opportunity> qualifiedOpportunities) {
            updateAccounts(getAccounts(qualifiedOpportunities));
            return true;
        }

        public Boolean run(TriggerAfterUpdate.Context currentContext, List<Opportunity> qualifiedOpportunities) {
            updateAccounts(getAccounts(qualifiedOpportunities));
            return true;
        }

        private Set<Id> getAccounts(List<Opportunity> opportunities) {
            Set<Id> result = new Set<Id>();
            for(Opportunity opportunity : opportunities) {
                result.add(opportunity.AccountId);
            }
            return result;
        }

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
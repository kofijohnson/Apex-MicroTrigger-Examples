public with sharing class OpportunityPayment_MT {
    
    /*******************************************************************************************************
    * @description 
    * instantianted 
    ********************************************************************************************************/
    public class PaymentsFilter implements TriggerAfterInsert.Criteria, TriggerAfterUpdate.Criteria {
        
        /*******************************************************************************************************
        * @description Before Insert
        ********************************************************************************************************/
        public List<Payment__c> run(TriggerAfterInsert.Context currentContext) {
            List<Payment__c> result = new List<Payment__c>();
     
            for(Payment__c newPayment : (List<Payment__c>) currentContext.newList) {
                if(newPayment.Amount__c > 0) {
                    result.add(newPayment);
                }
            }
            return result;
        }

        /*******************************************************************************************************
        * @description Before Update
        ********************************************************************************************************/
        public List<Payment__c> run(TriggerAfterUpdate.Context currentContext) {
            List<Payment__c> result = new List<Payment__c>();
     
            for(Payment__c newPayment : (List<Payment__c>) currentContext.newList) {
                Payment__c oldPayment = (Payment__c) currentContext.oldMap.get(newPayment.Id);
                if(oldPayment.Amount__c != newPayment.Amount__c) {
                    result.add(newPayment);
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
    
        public Boolean run(TriggerAfterInsert.Context currentContext, List<Payment__c> qualifiedPayments) {
            updateOpportunitiesBalance(getOpportunities(qualifiedPayments));
            return true;
        }

        public Boolean run(TriggerAfterUpdate.Context currentContext, List<Payment__c> qualifiedPayments) {
            updateOpportunitiesBalance(getOpportunities(qualifiedPayments));
            return true;
        }

        private Set<Id> getOpportunities(List<Payment__c> payments) {
            Set<Id> result = new Set<Id>();
            for(Payment__c payment : payments) {
                result.add(payment.Opportunity__c);
            }
            return result;
        }

        private void updateOpportunitiesBalance(Set<Id> opportunityIds) {
            List<Opportunity> opportunities = [
                SELECT Amount, Balance__c, (
                    SELECT Amount__c
                    FROM Payments__r
                )
                FROM Opportunity
                WHERE Id IN :opportunityIds
            ];
            for(Opportunity opportunity : opportunities) {
                Decimal opportunityPayments = 0;
                for (Payment__c payment : opportunity.Payments__r) {
                    opportunityPayments += payment.Amount__c;
                }
                opportunity.Balance__c = opportunity.Amount - opportunityPayments;
            }
            update opportunities;
        }
    }
}
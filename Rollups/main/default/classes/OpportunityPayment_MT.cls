/*******************************************************************************************************
* @Description: Opportunity Payments Rollup MicroTrigger Class.
* @Author: Kofi Johnson - https://github.com/kofijohnson
********************************************************************************************************/

public with sharing class OpportunityPayment_MT {
    
    /*******************************************************************************************************
    * @description Criteria Object that will be used to find the inserted Payments (with Amount greater than 0)
    * or the Payments whose Amount changed. This Criteria implements TriggerAfterInsert.Criteria,
    * TriggerAfterUpdate.Criteria, because it needs to run in After Insert and Update Trigger context.
    ********************************************************************************************************/
    public class PaymentsFilter implements TriggerAfterInsert.Criteria, TriggerAfterUpdate.Criteria {
        
        /*******************************************************************************************************
        * @description Implementation of the TriggerAfterInsert.Criteria Interface. Gets the created Payments
        * with Amount greater than 0.
        * @param TriggerAfterInsert.Context The After Insert Trigger Context.
        * @return List<Payment__c> The created Payments with Amount greater than 0.
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
        * @description Implementation of the TriggerAfterUpdate.Criteria Interface. Gets the Payments whose
        * Amount changed.
        * @param TriggerAfterUpdate.Context The After Update Trigger Context.
        * @return List<Payment__c> The created Payments whose Amount changed.
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
    * @description Action Object that will be used to update the Balance field on the Opportunities. This Action 
    * implements TriggerAfterInsert.Action, TriggerAfterUpdate.Action, because it needs to run in After Insert
    * and Update Trigger context.
    ********************************************************************************************************/
    public class PaymentRollup implements TriggerAfterInsert.Action, TriggerAfterUpdate.Action {
        
        /*******************************************************************************************************
        * @description Implementation of the TriggerAfterInsert.Action Interface. Updates the Balance on Opportunities.
        * @param TriggerAfterInsert.Context The After Insert Trigger Context.
        * @param List<Payment__c>. The Payments returned by the Criteria Object.
        * @return Boolean. A flag that tells if the Action runs successfull or not.
        ********************************************************************************************************/
        public Boolean run(TriggerAfterInsert.Context currentContext, List<Payment__c> qualifiedPayments) {
            updateOpportunitiesBalance(getOpportunities(qualifiedPayments));
            return true;
        }

        /*******************************************************************************************************
        * @description Implementation of the TriggerAfterUpdate.Action Interface. Updates the Balance on Opportunities.
        * @param TriggerAfterUpdate.Context The After Update Trigger Context.
        * @param List<Payment__c>. The Payments returned by the Criteria Object.
        * @return Boolean. A flag that tells if the Action runs successfull or not.
        ********************************************************************************************************/
        public Boolean run(TriggerAfterUpdate.Context currentContext, List<Payment__c> qualifiedPayments) {
            updateOpportunitiesBalance(getOpportunities(qualifiedPayments));
            return true;
        }

        /*******************************************************************************************************
        * @description Gets the Payments Opportunity Ids.
        * @param List<Payment__c>. The Payments.
        * @return Set<Id>. The Opportunity Ids
        ********************************************************************************************************/
        private Set<Id> getOpportunities(List<Payment__c> payments) {
            Set<Id> result = new Set<Id>();
            for(Payment__c payment : payments) {
                result.add(payment.Opportunity__c);
            }
            return result;
        }

        /*******************************************************************************************************
        * @description Updates the Opportunities Balance.
        * @param Set<Id>. The Opportunities to update.
        * @return void.
        ********************************************************************************************************/
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
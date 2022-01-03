import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ReplicateData from '@salesforce/apex/AccountReplicationProcess.replicateData';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCNUMBER_FIELD from '@salesforce/schema/Account.AccountNumber';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import ANNUAL_REVEUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import RATING_FIELD from '@salesforce/schema/Account.Rating';

export default class CloneAccRecToServerLWC extends LightningElement {
    @api recordId;
    accountRecord;

    @wire(getRecord, { recordId:'$recordId', fields: [NAME_FIELD, ACCNUMBER_FIELD, INDUSTRY_FIELD, ANNUAL_REVEUE_FIELD, RATING_FIELD] })
    getAccRecord({data,error})    {
        if(data)    {
            this.accountRecord = data.fields;
        }
        else if(error)  {
            console.error(error);
        }
    }

    @api invoke()   {
        console.log('Acc:',this.accountRecord);
        this.accCloneToServer(this.accountRecord);
    }

    accCloneToServer(accRecord)  {
        let inputParams = {};
        for(let key in accRecord)  {
            inputParams = {...inputParams, [key]:accRecord[key].value};
          } 

          //Call Apex Method and it return Promise
          ReplicateData({ pName:inputParams.Name, pAccountNumber:inputParams.AccountNumber, pIndustry:inputParams.Industry, 
                          pAnnualRevenue:inputParams.AnnualRevenue, pRating:inputParams.Rating })
          .then(success=>   {
            console.log('Acc ID:',JSON.stringify(success));
            this.showToast('Account Created',`Account ${success} is created successfully`,'success');

          }).catch(error=>  {
              console.error(error);
              this.showToast('Error Occured !!',error.message,'error');
          })
    }

    showToast(title, message, variant)  {
        const custToastEvent = new ShowToastEvent({
            title: title,
            message:message,
            variant:variant 
        }) 

        this.dispatchEvent(custToastEvent);
    }

}
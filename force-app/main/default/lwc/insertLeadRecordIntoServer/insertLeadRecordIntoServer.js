import { LightningElement, wire } from 'lwc';
import { getObjectInfo,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import InsertLeadRecord from '@salesforce/apex/LeadControllerServerIntegration.InsertLeadRecord';
import LEAD_OBJECT from '@salesforce/schema/Lead';  

export default class InsertLeadRecordIntoServer extends LightningElement {
    formFields = {};
    industryOptions = [];
    leadSourceOptions = [];

    //get Lead Objkect Information
    @wire(getObjectInfo,{objectApiName:LEAD_OBJECT})
    getLeadInfo;

    //Get Default Record Type ID of Lead Object 
    @wire(getPicklistValuesByRecordType,{objectApiName:LEAD_OBJECT, recordTypeId:'$getLeadInfo.data.defaultRecordTypeId'})
    getPickListDetails({data, error})   {
        if(data)    {
            this.industryOptions = this.picklistGenerator(data.picklistFieldValues.Industry);
            this.leadSourceOptions = this.picklistGenerator(data.picklistFieldValues.LeadSource);
        }
        if(error)   {
            console.error(error);
        }
    }

    picklistGenerator(data) {
        let optionList = data.values.map(curritem=>  {
            return { 'label':curritem.label, 'value':curritem.value };
        })
        return optionList;
    }

    resetAllFields()    {
        const allElements = this.template.querySelector('form.createForm');
        allElements.reset();
        this.formFields = {};
    }

    changeHandler(event)    {
        //Destructing to variables
        const {name, value} = event.target;
        this.formFields[name] = value;
    }

    createLeadHandler(event)    {
        console.log(this.formFields);
        //Call Apex Method
        InsertLeadRecord({fName:this.formFields.FirstName, lName:this.formFields.LastName, leadCompany:this.formFields.CompanyName, leadEmail:this.formFields.Email,
                          leadIndustry:this.formFields.Industry, leadSource:this.formFields.LeadSource, leadPhone:this.formFields.Phone})
        .then(result=>  {
            console.log(result);
            this.resetAllFields();
            this.showToastMessage('records created !!',result,'success');
        }).catch(error=>    {
            console.error(error);
            this.showToastMessage('Error Occured',JSON.stringify(error.message),'error');
        }) 
    }

    showToastMessage(title,message,variant) {
        let customToastEvent = new ShowToastEvent({
            title:title,
            message:message,
            variant:variant     
        });
        this.dispatchEvent(customToastEvent);
    }
}
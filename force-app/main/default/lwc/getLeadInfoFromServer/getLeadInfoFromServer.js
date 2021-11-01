import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetLeadRecords from '@salesforce/apex/LeadControllerServerIntegration.GetLeadRecords';
import DeleteLeadRecord from '@salesforce/apex/LeadControllerServerIntegration.DeleteLeadRecord';
import UpdateLeadRecord from '@salesforce/apex/LeadControllerServerIntegration.UpdateLeadRecord';

// row actions
const ACTIONS = [
    { label: 'Edit Email', name: 'edit'}, 
    { label: 'Delete', name: 'delete'}
];

const COLS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Lead Source', fieldName: 'LeadSource', type: 'text' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Rating', fieldName: 'Rating', type: 'text' },
    { 
        type: 'action', 
        typeAttributes: {
            rowActions: ACTIONS,
            menuAlignment: 'right'
        }
    }
];

export default class GetLeadInfoFromServer extends LightningElement {
    searchText = '';
    selectedOption = '';
    currentEditRecord = {};
    toggleSpinner = false;
    leadRecords = [];
    isEditForm = false;
    isShowModal = false;
    columns = COLS;

    onChangeHandler(event)  {
        this.searchText = event.target.value;
    }

    //Get radio Options
    get radioOptions()  {
        return [
            { label: 'Username-Password Flow', value: 'option1' },
            { label: 'JWT Bearer Flow for Server-to-Server Integration', value: 'option2' },
        ];
    }

    //When user clicks on Radio button
    handleRadioChange(event)    {
        this.selectedOption = event.target.value;
    }

    clickHandler(event) {
        let searchText = this.template.querySelector('.SearchLead');
        let searchTextval = searchText.value;
        
        if(!searchTextval)  {
            searchText.setCustomValidity('Please Enter Search Text');    
        } else  {
            searchText.setCustomValidity('');
            this.toggleSpinner = true;
            //Call Apex Method
            GetLeadRecords({SearchTerm:this.searchText, SelectOption:this.selectedOption})
            .then(result=>  {
                this.leadRecords = result;
                this.toggleSpinner = false;
                console.log('Records :', this.leadRecords);    
                this.showToastMessage('records found !!',`${this.leadRecords.length} Lead records retrieved from Server`,'success');
            }).catch(error=>  {
                this.leadRecords = undefined;
                console.error(error);
                this.toggleSpinner = false;
                this.showToastMessage('Error Occured',JSON.stringify(error.message),'error');
            })

        }
        searchText.reportValidity();
    }

    handleRowActions(event)  {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        window.console.log('row ====> ' + JSON.stringify(row));

        switch(actionName)  {
            case 'edit':
                this.editCurrentRecord(row);
                break;

            case 'delete':
                this.deleteLeadRecord(row);
                break;
        }
    }

    editCurrentRecord(currentRow)   {
        this.isEditForm = true;
        this.isShowModal = true;
        this.currentEditRecord = {
            'Id': currentRow.Id,
            'Email': currentRow.Email,
            'NewEmail': ''
        }
    }

    deleteLeadRecord(currentRow)    {
        let currentRecordId = currentRow.Id;
        this.toggleSpinner = true;
        //calling apex class method to delete the selected Lead from Server
        DeleteLeadRecord({LeadId:currentRecordId})
        .then(result=>  {
            const index = this.findRowIndexById(currentRecordId);
            let arr1 = this.leadRecords.slice(0, index);
            let arr2 = this.leadRecords.slice(index + 1);
            this.leadRecords = arr1.concat(arr2);
            this.toggleSpinner = false;
            //Message showing
            console.log(result);
            this.showToastMessage('Record Deleted',result,'success');

        }).catch(error=>    {
            console.error(error);
            this.leadRecords = undefined;
            this.toggleSpinner = false;
            this.showToastMessage('Error Occured',JSON.stringify(error.message),'error');
        })
    }

    findRowIndexById(recId) {
        let ret = -1;
        this.leadRecords.some((currItem,index)=>    {
            if(currItem.Id === recId)   {
                ret =  index;
                return true;   
            }   
            return false;
        })
        return ret;
    }

    onEmailChange(event)    {
        this.currentEditRecord.NewEmail = event.target.value;       
    }

    //For Modal Update Email Button
    updateEmailhandler(event)   {
        console.log(this.currentEditRecord);
        this.isEditForm = false;
        this.isShowModal = false;
        this.toggleSpinner = true;
        //Call Apex method to update Email ID
        UpdateLeadRecord({LeadId:this.currentEditRecord.Id, NewEmailId:this.currentEditRecord.NewEmail})
        .then(result=>  {
            //Update Email in the current reocrd of datatable
            // const index = this.findRowIndexById(this.currentEditRecord.Id);
            // let updateObj = {...this.leadRecords[index], 'Email':this.currentEditRecord.NewEmail};
            // this.leadRecords = [...this.leadRecords.slice(0,index),
            //                     updateObj,
            //                     ...this.leadRecords.slice(index + 1), 
            //                    ];

            this.leadRecords = this.leadRecords.map(item => {
               return item.Id === this.currentEditRecord.Id ? { ...item, 'Email':this.currentEditRecord.NewEmail } : item;
            });
            console.log('Records :', this.leadRecords);

            this.toggleSpinner = false;
            this.showToastMessage('Record Updated',result,'success');
        }).catch(error=>    {
            this.toggleSpinner = false;
            console.error(error);
            this.showToastMessage('Error Occured',JSON.stringify(error.message),'error');
        })
    }

    //For Modal Cancel Button
    cancelHandler(event)    {
        this.isEditForm = false;
        this.isShowModal = false;    
        this.currentEditRecord = {};
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
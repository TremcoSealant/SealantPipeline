import { LightningElement, track, wire, api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import hasCPQQuoteApprover from '@salesforce/customPermission/CPQQuoteApprover';
import updateQuoteLines from '@salesforce/apex/TC_CPQQuoteLineEditor.updateQuoteLines';
import getQuoteDetails from '@salesforce/apex/ensxtx_CTRL_SalesDocDetail.getDetail';
import getApprover from '@salesforce/apex/TC_CPQQuoteLineEditor.getApprover';
import getQuoteLines from '@salesforce/apex/TC_CPQQuoteLineEditor.getQuoteLines';
import getPricing from '@salesforce/apex/TC_CPQQuoteLineEditor.getPricing';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import hasCPQDebugPermission from '@salesforce/customPermission/CPQ_Debug';

//HTML Labels
import Tremco_Quotes_ErrorText from '@salesforce/label/c.Tremco_Quotes_ErrorText';
import Tremco_Quotes_WarningText from '@salesforce/label/c.Tremco_Quotes_WarningText';
import Tremco_Quotes_ConfigurePricing from '@salesforce/label/c.Tremco_Quotes_ConfigurePricing';
import Tremco_Quotes_LineError from '@salesforce/label/c.Tremco_Quotes_LineError';
import Tremco_Quotes_UnsavedChanges from '@salesforce/label/c.Tremco_Quotes_UnsavedChanges';
import Tremco_Quotes_GetPricing from '@salesforce/label/c.Tremco_Quotes_GetPricing';
import Tremco_Quotes_Cancel from '@salesforce/label/c.Tremco_Quotes_Cancel';
import Tremco_Quotes_Save from '@salesforce/label/c.Tremco_Quotes_Save';
import Tremco_Quotes_SaveSubmit from '@salesforce/label/c.Tremco_Quotes_SaveSubmit';
import Tremco_Quotes_ConfirmDelete from '@salesforce/label/c.Tremco_Quotes_ConfirmDelete';
import Tremco_Quotes_DeleteConfirmation from '@salesforce/label/c.Tremco_Quotes_DeleteConfirmation';
import Tremco_Quotes_Confirm from '@salesforce/label/c.Tremco_Quotes_Confirm';
import Tremco_Quotes_Comments from '@salesforce/label/c.Tremco_Quotes_Comments';
import Tremco_Quotes_CancelConfirmation from '@salesforce/label/c.Tremco_Quotes_CancelConfirmation';
import Tremco_Quotes_CancelConfirmationMsg from '@salesforce/label/c.Tremco_Quotes_CancelConfirmationMsg';
import Tremco_Quotes_Yes from '@salesforce/label/c.Tremco_Quotes_Yes';
import Tremco_Quotes_No from '@salesforce/label/c.Tremco_Quotes_No';
import Tremco_Quotes_SubmitApproval from '@salesforce/label/c.Tremco_Quotes_SubmitApproval';
import Tremco_Quotes_EnterComments from '@salesforce/label/c.Tremco_Quotes_EnterComments';
import Tremco_Quotes_SubmitForApproval from '@salesforce/label/c.Tremco_Quotes_SubmitForApproval';

//JS Toast Labels
import Tremco_Quotes_AddMaterialGroupError from '@salesforce/label/c.Tremco_Quotes_AddMaterialGroupError';
import Tremco_Quotes_ResolveLineErrors from '@salesforce/label/c.Tremco_Quotes_ResolveLineErrors';
import Tremco_Quotes_QuoteSaved from '@salesforce/label/c.Tremco_Quotes_QuoteSaved';
import Tremco_Quotes_ErrorUpdating from '@salesforce/label/c.Tremco_Quotes_ErrorUpdating';
import Tremco_Quotes_CompleteFields from '@salesforce/label/c.Tremco_Quotes_CompleteFields';

export default class QuoteLineEditor extends LightningElement {

    logDebug(...messages) {
        if (hasCPQDebugPermission) {
            console.log(...messages);
        }
    }

    get labels() {
        return {
            errorText: Tremco_Quotes_ErrorText,
            warningText: Tremco_Quotes_WarningText,
            configurePricing: Tremco_Quotes_ConfigurePricing,
            lineError: Tremco_Quotes_LineError,
            unsavedChanges: Tremco_Quotes_UnsavedChanges,
            getPricing: Tremco_Quotes_GetPricing,
            cancel: Tremco_Quotes_Cancel,
            save: Tremco_Quotes_Save,
            saveSubmit: Tremco_Quotes_SaveSubmit,
            confirmDelete: Tremco_Quotes_ConfirmDelete,
            deleteConfirmation: Tremco_Quotes_DeleteConfirmation,
            confirm: Tremco_Quotes_Confirm,
            comments: Tremco_Quotes_Comments,
            cancelConfirmation: Tremco_Quotes_CancelConfirmation,
            cancelConfirmationMsg: Tremco_Quotes_CancelConfirmationMsg,
            yes: Tremco_Quotes_Yes,
            no: Tremco_Quotes_No,
            submitApproval: Tremco_Quotes_SubmitApproval,
            enterComments: Tremco_Quotes_EnterComments,
            submitForApproval: Tremco_Quotes_SubmitForApproval,
            addMaterialGroupError: Tremco_Quotes_AddMaterialGroupError,
            resolveLineErrors: Tremco_Quotes_ResolveLineErrors,
            quoteSaved: Tremco_Quotes_QuoteSaved,
            errorUpdating: Tremco_Quotes_ErrorUpdating,
            completeFields: Tremco_Quotes_CompleteFields
        };
    }
    
    @api recordId;
    @api objectApiName;
    showDisabled = false;
    @track showUpdateDisabled = false;
    isSubmitted = false;
    isAccepted = false;

    // Tracking properties
    @track approver;
    @track requestItems = [];
    @track hasLineErrors = false;
    @track hasPendingChanges = false;
    @track submitForApproval = false;
    @track pricingLoaded = false;
    @track showCancelConfirmation = false;
    @track showSubmitForApprovalModal = false;
    @track showMarginWarningModal = false;
    @track quoteAccountId;
    @track requestObj = {};
    @track openForUpdates = false;      //SSN-69 - Aza
    showSpinner = false;
    @track showButtonGroup = false;
    isApprover = false;
    marginWarningAcknowledged = false;

    //Modal
    @track showModalConfirmation = false;
    @track showApproveModalConfirmation = false;
    @track approveTitle = ''; // Set a default value or fetch it from somewhere
    @track approveButton = ''; // Set a default value or fetch it from somewhere

    // custom permission used to control view of specific fields
    get hasApprover(){
        return hasCPQQuoteApprover ? hasCPQQuoteApprover : false;
    }
    // SSN-4
    get isSapQuoteNumberPresent() {
        return this.sapQuoteNumber !== null && this.sapQuoteNumber !== '' && this.sapQuoteNumber !== undefined;
    }

    get showDryvitTintingButton() {     //SSN-69 - Aza
        return !this.isSapQuoteNumberPresent || this.openForUpdates;
    }
    
    userId = USER_ID;
    
    // Function to make the imperative call
    checkApproverStatus() {
        // console.log ('getApprover for '+this.recordId);
        getApprover({ userId: this.userId, recordId: this.recordId })
            .then(result => {
                // console.log('isApprover ' + result.isApprover);
                this.isApprover = result.isApprover;
                this.stepId = result.stepId;
                // set disabled/approval state
                this.showDisabled = (this.isSubmitted || this.isAccepted || this.openForUpdates) && !this.isApprover;
            })
            .catch(error => {
                this.error = error;
                console.log('isApprover ' + this.error);
                this.showSpinner = false;
            }).finally(() => {
            });
    }

    @track sapQuoteNumber; 

    fetchQuoteLines() {
        // console.log('fetchQuoteLines for ' + this.recordId);
        this.showButtonGroup = false;
    
        return getQuoteLines({ recordId: this.recordId })
            .then(result => {
                this.hasPendingChanges = false;
                this.marginWarningAcknowledged = false;
                this.requestObj = JSON.parse(JSON.stringify(result));       //SSN-69 - Aza
                this.requestItems = JSON.parse(JSON.stringify(result.quoteLines));
                this.isSubmitted = result.isSubmitted;
                this.isAccepted = result.isAccepted;
                this.quoteAccountId = result.quoteAccountId;
                this.openForUpdates = result.openForUpdates;
                this.sapQuoteNumber = result.sapQuoteNumber;
    
                // console.log('%Request Obj from Apex: ', this.requestObj, 'color: blue;');
                // console.log('%Request items from Apex: ', this.requestItems, 'color: blue;');
                // console.log('%cIs Submitted: ' + this.isSubmitted, 'color: blue;');
                // console.log('%cIs Accepted: ' + this.isAccepted, 'color: blue;');
                // console.log('%cOpen For Updates: ' + this.openForUpdates, 'color: blue;');
                // console.log('%cIs Approver: ' + this.isApprover, 'color: blue;');
    
                // set disabled/approval state
                this.showDisabled = (this.isSubmitted || this.isAccepted || this.openForUpdates) && !this.isApprover;
                // console.log('%cShowDisabled = ' + this.showDisabled, 'color: orange;');
    
                // Logic for showUpdateDisabled
                if (this.openForUpdates || this.isApprover){
                    this.showUpdateDisabled = false;
                } else if(this.showDisabled && !this.openForUpdates) {
                    this.showUpdateDisabled = true;
                }
                // console.log('%cShowUpdateDisabled = ' + this.showUpdateDisabled, 'color: orange;');
    
                // Get ITEM_USER_DEFINED details and process them
                return getQuoteDetails({ "documentNumber": this.sapQuoteNumber })
                .then(quoteDetailsResult => {
                    // console.log('Full response from getQuoteDetails:', quoteDetailsResult);
            
                    // Directly access asList which is confirmed to be an array
                    const itemUserDefinedList = quoteDetailsResult.data.ITEM_USER_DEFINED.asList;
                    // console.log("asList data:", itemUserDefinedList);
                    
                    // Process asList data
                    this.requestItems.forEach(quoteLine => {
                        itemUserDefinedList.forEach(itemUserDefined => {
                            // console.log("Run check", itemUserDefined.SalesItem, quoteLine.sapItemNumber, itemUserDefined.FIELD);
                            if (itemUserDefined.SalesItem === quoteLine.sapItemNumber && itemUserDefined.FIELD === "ORFMNG") {
                                quoteLine.remainingQty = parseFloat(itemUserDefined.VALUE.trim());
                            }
                        });
                    });
            
                    // Now that we have updated quote lines, fetch pricing for them
                    return this.handlePricing(); // Assuming handlePricing returns a Promise
                })
                .catch(error => {
                    console.error('Error in getQuoteDetails:', error);
                });
            })
            .catch(error => {
                this.error = error;
                console.log('Quote error' + JSON.stringify(this.error));
                this.showSpinner = false;
                throw error; // Re-throw the error to handle it in the caller
            })
            .finally(() => {
                this.isSubmitted = (this.isSubmitted == true && this.isApprover == true) ? false : this.isSubmitted;
                this.showButtonGroup = true;
                // Additional final actions if needed
            });
    }
    
    

    connectedCallback() {
        // console.log('In ConnectedCallback isApprover', this.isApprover);
        this.showSpinner = true;
        setTimeout(() => {
            // console.log('Delayed recordId:', this.recordId);
            this.checkApproverStatus();
            this.fetchQuoteLines() // This now includes pricing logic
                .then(() => {

                    // console.log("Quote lines and pricing fetched successfully");
                })
                .catch(error => {
                    console.log("Error fetching quote lines or pricing:", error);
                });
        }, 1000); // Delay for testing purposes
    }

handleItemChange(event){
    // console.log('**Parent received item change**', event.detail);
    this.hasPendingChanges = true;
    let newItem = event.detail;

    if (newItem.Id) {
        let i = this.requestItems.findIndex(item => item.Id === newItem.Id);

        // Update line
        this.requestItems[i] = newItem;
    }

    this.marginWarningAcknowledged = false;

    return true; // Since we're not checking for duplicates, success is always true
}
    //SSN-316-Aza
    get hasMarginWarningLines() {
        return this.requestItems.some(item => {
            const bookPrice = parseFloat(item?.bookPrice);
            const margin = parseFloat(item?.margin);
            return !isNaN(bookPrice) && bookPrice > 0 && !isNaN(margin) && margin <= 0;
        });
    }


    updateLineNumbers() {
        let random = Math.floor(Math.random() * 10000);
        this.requestItems = this.requestItems.map((item, index) => {
            // console.log(index);
            // console.log(item);
            let lineNumber = index + random;
            item.lineNumber = lineNumber;
            item.Id = 'item'+ lineNumber;
            return item;
        });
    }

    @track itemToDelete;
    deletedLines = [];

     // delete lines
    handleDelete(event) {
        //console.log("Received delete event for item ID:", event.detail);
        //console.log("Current requestItems:", JSON.stringify(this.requestItems));
        const itemId = event.detail;
        const itemToDelete = this.requestItems.find(item => item.Id === itemId);
        //console.log("Item to delete:", JSON.stringify(itemToDelete));
        if (itemToDelete) {
            //console.log('am inside');
            this.showModalConfirmation = true;
            this.itemToDelete = itemToDelete;
            this.handleModalConfirmation();
            this.handleModalCancel();
        }
        //this.requestItems = this.requestItems.filter(item => item.Id !== itemId);

    }

    // delete confimation modal cancel
    handleModalCancel(){
        this.itemToDelete = null;
        this.showModalConfirmation = false;
    }

    // delete confimation modal confim
    handleModalConfirmation() {
    
        // console.log("Confirming deletion for:", JSON.stringify(this.itemToDelete));

    let i = this.requestItems.findIndex(item => item.Id == this.itemToDelete.Id);
    this.requestItems.splice(i, 1);

    // console.log("Deleted item at index:", i);
    // console.log("Updated requestItems:", JSON.stringify(this.requestItems));
       
        if(this.itemToDelete.recordId){
            this.deletedLines.push(this.itemToDelete.recordId);
            console.log(this.deletedLines);
        }
        this.showModalConfirmation = false;
        this.itemToDelete = null;
        this.marginWarningAcknowledged = false;

        // Update line numbers of remaining items
        this.updateLineNumbers();
        this.checkLineErrors();
        this.hasPendingChanges = true;
    }


    checkLineErrors() {
        //SSN-340-Aza
        // Only non-discontinued line errors should block submit and trigger the top banner.
        this.hasLineErrors = this.requestItems.some(item => this.isBlockingLineError(item));
    
        // Log the error status
        // console.log('Updated hasLineErrors to:', this.hasLineErrors);
    }
    //SSN-340-Aza
    isBlockingLineError(item) {
        return item?.hasErrors === true && item?.errorIsDiscontinued !== true;
    }

    getSubmittableItems() {
        //SSN-340-Aza
        return (this.requestItems || []).filter(item => item?.errorIsDiscontinued !== true);
    }

    handleSubmitForApproval(){
        if(this.hasLineErrors == true){
            this.showToast('error', this.labels.resolveLineErrors, null);
            return;
        }
        //SSN-340-Aza
        if (this.getSubmittableItems().length === 0) {
            //SSN-340-Aza
            this.showToast('error', 'Validation Error', 'All line items are discontinued. Add at least one active line before submitting.');
            return;
        }

        const endDateValidation = this.validateEndDate(this.requestObj.quoteEndDate);

        if (!endDateValidation.isValid) {
            this.showToast('error', 'Validation Error', endDateValidation.message);
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return; // Stop the submission process
        }

        if (this.hasDuplicateDryvitLines()) {
            this.showToast('error', 'Validation Error', 'Duplicate Dryvit lines found with the same finish and color.');        //SSN-249 - Aza
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return; // Stop the submission process
        }

        if (this.hasIncompleteDryvitLines()) {
            this.showToast('error', 'Validation Error', 'You must select a Product and Color for your Dryvit Tintable Product');
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return; // Stop the submission process
        }

        if (this.hasInvalidQuantityLines()) {
            this.showToast('error', 'Validation Error', 'One or more items have a quantity of zero or negative.');
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return; // Stop the submission process
        }
        //SSN-316-Aza
        if (this.hasMarginWarningLines && !this.marginWarningAcknowledged) {
            this.showMarginWarningModal = true;
            return;
        }

        this.showSubmitForApprovalModal = true;
    }
    //SSN-316-Aza
    handleMarginWarningAcknowledge() {
        this.marginWarningAcknowledged = true;
        this.showMarginWarningModal = false;
    }

    handleApprovalModalCancelForSubmission() {
        this.showSubmitForApprovalModal = false;
        this.isSubmitted = false;
    }

    handleApprovalCommentsConfirmationForSubmission() {
        this.showSubmitForApprovalModal = false;
        this.submitForApproval = true;
        this.isSubmitted = true;
        this.handleSubmit(true); // Proceed with submission
    }
    

    // Method to handle approval comments change
    handleInitialApprovalComments(event) {
    this.initialApprovalComments = event.target.value;
    }

    handleInputChange(event) {
        const fieldId = event.target.dataset.id;
        const fieldValue = event.target.value;
        // console.log(`Field Changed: ${fieldId}, New Value: ${fieldValue}`);

        // Check if the changed field is 'endDate'
        if (fieldId === 'endDate') {
            this.requestObj.quoteEndDate = fieldValue; // Update the quoteEndDate
            // console.log(`End Date Updated: ${this.requestObj.quoteEndDate}`);
        }
    }




    handleSubmit(submitForApproval) {
        this.showSpinner = true;
        this.showDisabled = true;
        this.requestObj.quoteLines = this.requestItems;
        //SSN-340-Aza
        if (submitForApproval && this.getSubmittableItems().length === 0) {
            //SSN-340-Aza
            this.showToast('error', 'Validation Error', 'All line items are discontinued. Add at least one active line before submitting.');
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return;
        }
        this.allValid = true; // Assuming this is set correctly earlier

        
        const endDateValidation = this.validateEndDate(this.requestObj.quoteEndDate);

        if (!endDateValidation.isValid) {
            this.showToast('error', 'Validation Error', endDateValidation.message);
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return; // Stop the submission process
        }

        if (this.hasDuplicateDryvitLines()) {
            this.showToast('error', 'Validation Error', 'Duplicate Dryvit lines found with the same finish and color.');        //SSN-249 - Aza
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return; // Stop the submission process
        }

        if (this.hasIncompleteDryvitLines()) {
            this.showToast('error', 'Validation Error', 'You must select a Product and Color for your Dryvit Tintable Product');
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return; // Stop the submission process
        }

        if (this.hasInvalidQuantityLines()) {
            this.showToast('error', 'Validation Error', 'One or more items have a quantity of zero or negative.');
            this.showSpinner = false;
            this.showDisabled = false;
            this.submitForApproval = false;
            this.isSubmitted = false;
            return; // Stop the submission process
        }

        // if (submitForApproval) {
        //     // Check for negative, zero, or blank prices only when submitting for approval
        //     const hasInvalidPrice = this.requestItems.some(item => 
        //         item.price <= 0 || item.price === undefined || item.price === ''
        //     );
        
        //     if (hasInvalidPrice) {
        //         this.showToast('error', 'Validation Error', 'One or more items have an invalid price.');
        //         this.showSpinner = false;
        //         this.showDisabled = false;
        //         this.submitForApproval = false;
        //         this.isSubmitted = false;
        //         return; // Stop the submission process
        //     }
        // }
        
    
        if(this.allValid) {    
            // Call Apex to save the request
            console.log('Request ' + JSON.stringify(this.requestObj));
            console.log('RequestObj', this.requestObj);
            // console.log('this.submitForApproval', this.submitForApproval);
            updateQuoteLines({ 
                requestObj : JSON.stringify(this.requestObj),
                deletedLines : JSON.stringify(this.deletedLines),
                submitForApproval : this.submitForApproval,
                initialApprovalComments: this.initialApprovalComments
            })
            .then((results) => {
                // console.log('Results ' + JSON.stringify(results));
                if(results) {
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    return this.fetchQuoteLines(); // Fetch the quote lines which includes pricing logic
                } else {
                    throw new Error('Error updating record');
                }
            })
            .then(() => {
                // console.log('All operations completed successfully');
                this.showToast('success', this.labels.quoteSaved, null);
            })
            .catch((error) => {
                console.error('Error:', JSON.stringify(error, null, 4)); // Logging the full error for debugging
            
                let errorMessage = 'There was an error saving the Quote';
                if (error && error.message) {
                    errorMessage += ': ' + error.message; // Append the actual error message from Apex
                } else {
                    errorMessage += '. Unknown error'; // Fallback error message
                }
            
                this.showToast('error', 'Error', errorMessage);
                this.showDisabled = false;
                this.submitForApproval = false;
                this.isSubmitted = false;
            })
            .finally(() => {
                eval("$A.get('e.force:refreshView').fire();");
                this.showSpinner = false;
                this.deletedLines = [];
            });
        } else {
            this.showToast('error', this.labels.completeFields, null);
            this.showSpinner = false;
            this.showDisabled = false;
                this.submitForApproval = false;
                this.isSubmitted = false;
        }
    }

    validateEndDate(endDate) {
        if (!endDate) {
            return { isValid: false, message: 'End date is not set.' };
        }
        
        const today = new Date();
        const endDateObj = new Date(endDate);
        const thirtyDaysLater = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);
    
        if (endDateObj < thirtyDaysLater) {
            return { isValid: false, message: 'End date must be at least 30 days from today.' };
        }
    
        return { isValid: true, message: '' };
    }
    
    closeModal(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCancel(){
        this.showCancelConfirmation = true;
    }

    handleCancelConfirmationCancel() {
        // Hide the cancel confirmation modal
        this.showCancelConfirmation = false;
    }
    
    // Method to handle the confirmation of the cancel action
    handleCancelConfirmationConfirm() {
        // Hide the cancel confirmation modal and reload the page
        this.showCancelConfirmation = false;
        window.location.reload();
    }

    @api 
    handleChildPricingRequest(lineItem){
        this.handlePricing();
    }

handlePricing() {
    this.showSpinner = true;

    if (!this.requestItems || this.requestItems.length === 0) {
        console.error("No request items to process");
        this.showSpinner = false;
        return;
    }

    const sendItemForPricing = (item, index) => {
        let quoteLinesArray = JSON.stringify([item]);
        console.log("quoteLinesArray "+quoteLinesArray);
        return getPricing({ quoteLines: quoteLinesArray })
            .then(result => {
                return { index, result }; // Return an object with the index and the result
            })
            .catch(error => {
                console.error(`Error in pricing item ${index + 1}:`, JSON.stringify(error.message, null, 4));
                return { index, error }; // Include the index even in case of error
            });
    };

    const promises = this.requestItems.map((item, index) => sendItemForPricing(item, index));

    return Promise.all(promises)
        .then(responses => {
            // Create an array to hold the results in order
            let orderedResults = new Array(this.requestItems.length);

            responses.forEach(response => {
                if (response.error) {
                    // Handle error for the individual item
                    console.error(`Error in item at index ${response.index}:`, response.error);
                } else {
                    // Place the result in the correct position
                    orderedResults[response.index] = response.result;
                }
            });

            // Flatten and filter out undefined values
            this.requestItems = orderedResults.flat().filter(item => item !== undefined);
            this.marginWarningAcknowledged = false;

            console.log("Updated requestItems with ordered responses:", this.requestItems);
        })
        .catch(error => {
            console.error('Error in processing pricing:', JSON.stringify(error.message, null, 4));
            this.showToast('error', 'Error', error.body.message);
        })
        .finally(() => {
            this.checkLineErrors();
            this.pricingLoaded = true;
            setTimeout(() => {
                this.showSpinner = false;
                console.log('Pricing process completed.');
            }, 2000);
        });
}

draggedItemId;
dragOverItemId;

handleDragStart(event) {
    this.draggedItemId = event.target.dataset.id;
    event.dataTransfer.effectAllowed = "move";
    event.target.classList.add('dragging'); // Add class to dragged item
    console.log(`Dragging item with ID: ${this.draggedItemId}`);
}

handleDragOver(event) {
    event.preventDefault(); // Necessary to allow dropping
    console.log('Item is being dragged over another item');
    event.dataTransfer.dropEffect = "move";
}

handleDragEnter(event) {
    this.dragOverItemId = event.currentTarget.dataset.id;
    console.log(`Drag entered item with ID: ${this.dragOverItemId}`);
    event.currentTarget.classList.add('drop-target');
    // Rest of your code...
}

handleDragLeave(event) {
    // Remove class from drop target
    console.log(`Left item with ID: ${event.target.dataset.id}`);
    if (event.target.classList.contains('draggable-quote-line')) {
        event.target.classList.remove('drop-target');
    }
    // ... any additional logic if needed ...
}

handleDragEnd(event) {
    event.target.classList.remove('dragging');
    // Reset the dragged and drag over item IDs
    this.draggedItemId = null;
    this.dragOverItemId = null;
    console.log('Drag operation ended');
}

handleDrop(event) {
    event.preventDefault();
    const draggedIndex = this.findIndexById(this.draggedItemId);
    const dragOverIndex = this.findIndexById(this.dragOverItemId);

    if (draggedIndex !== dragOverIndex) {
        // Swap the items in the array
        const draggedItem = this.requestItems.splice(draggedIndex, 1)[0];
        this.requestItems.splice(dragOverIndex, 0, draggedItem);

        // Create new objects for each item to trigger reactivity
        this.requestItems = this.requestItems.map((item, index) => ({ ...item, sortOrder: index + 1 }));
        console.log('Updated requestItems after drop:', this.requestItems);
        this.hasPendingChanges = true;
    }

    // Clean up classes
    const elements = this.template.querySelectorAll('.draggable-quote-line');
    elements.forEach(el => {
        el.classList.remove('dragging');
        el.classList.remove('drop-target');
    });
    console.log(`Dropped item with ID: ${this.draggedItemId} over item with ID: ${this.dragOverItemId}`);
}


findIndexById(itemId) {
    return this.requestItems.findIndex(item => item.Id === itemId);
}
    

    showToast( type, title, msg ) {
        const event = new ShowToastEvent({
            variant : type,
            title   : title,
            message : msg
        });
        this.dispatchEvent( event );
    }
    
    handleAddItem() {
        //handles for when there are no existing quote lines 
        this.pricingLoaded = true;
        // Calculate the new line number based on the existing items
        // console.log('Before adding item - requestItems:', JSON.stringify(this.requestItems));
        // console.log('Before adding item - Length:', this.requestItems.length);
        // console.log('AccountId '+this.quoteAccountId);
    
        const newLineNumber = this.requestItems.length + 1;

        
    
        // Create a new item with default values and a unique Id
        const newItem = {
            account: this.quoteAccountId,
            approvalStatus: "",
            baseUom: "",
            baseUomPrice: 0,
            bookPrice: 0,
            cost: 0,
            cur: "",
            customerPrice: 0,
            discount: 0,
            errorIsDiscontinued: false,
            errorIsExcluded: false,
            errorNotIn2000: false,
            errorNotIn4000: false,
            errorNotInSAP: false,
            errorNotListed: false,
            hasErrors: false,
            Id: "item" + newLineNumber,
            isMaterialGroup: false,
            isSoldTo: false,
            isTradeDiscount: false,
            lineNumber: newLineNumber,
            margin: 0,
            materialNumber: "",
            maxDiscount: 0,
            price: 0,
            pricingUom: "",
            pricingUomPrice: 0,
            product2: "",
            productDetail: "",
            qty: 1,
            recordId: "",
            salesUom: "",
            salesUomPrice: 0,
            salesUomQty: 0,
            sortOrder: newLineNumber,
            tradeDiscount: 0,
            tradeDiscountPercentage: "",
            uom: null,
            uomOptions: "",
            isDryvit: true, 
            dryvitColorCode: "",
            dryvitProductCode: "",
            increment: 0,
            minimumOrderQty: 0,
            isApproved: false,
            remainingQty: 0,
            sapItemNumber: ''
        };
    
        // Push the new item into the requestItems array
        // console.log("New Item", newItem);
        this.requestItems.push(newItem);
    }


    get showUpdateButtonDisabled() {
        return !this.showUpdateDisabled;
    }

    handleUnlockForUpdate() {
        this.showUpdateDisabled = false;
        this.isSubmitted = false;
        this.openForUpdates = true;
        this.requestObj.openForUpdates = true;
    }

    handleRefresh() {
        // Show spinner while refreshing
        this.showSpinner = true;
    
        // Re-fetch data and refresh the component
        this.fetchQuoteLines()
            .then(() => {
                // Hide spinner after refresh
                eval("$A.get('e.force:refreshView').fire();");
                this.showSpinner = false;
                console.log("Component refreshed successfully");
            })
            .catch(error => {
                this.showSpinner = false;
                console.error("Error refreshing the component:", error);
                // Handle error (e.g., show a toast notification)
            });
    }

    hasDuplicateDryvitLines() {
        let dryvitLinesMap = new Map();
        for (let item of this.requestItems) {
            if (item.isDryvit) {
                
                let key = item.dryvitProductCode + '-' + item.dryvitColorId; // SSN-249 - Aza
                if (dryvitLinesMap.has(key)) {
                    return true; // Duplicate found
                }
                dryvitLinesMap.set(key, true);
            }
        }
        return false; // No duplicates found
    }

    
    hasIncompleteDryvitLines() {
        for (let item of this.requestItems) {
            if (item.isDryvit) {
                // Check if dryvitProductCode or dryvitColorCode is null, blank, or undefined
                if (!item.dryvitProductCode || !item.dryvitColorCode) {
                    return true; // Incomplete dryvit line found
                }
            }
        }
        return false; // No incomplete dryvit lines found
    }

    hasInvalidQuantityLines() {
        for (let item of this.requestItems) {
            // Check if qty is less than or equal to zero, or is undefined, or is an empty string
            if (item.qty <= 0 || item.qty === undefined || item.qty === '') {
                return true; // Invalid quantity line found
            }
        }
        return false; // No invalid quantity lines found
    }
    
    
    
    
}
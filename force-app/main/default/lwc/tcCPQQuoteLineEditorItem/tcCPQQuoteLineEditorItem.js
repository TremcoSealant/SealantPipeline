import { LightningElement, api, track } from 'lwc';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import getDryvitOptions from '@salesforce/apex/TC_CPQColorController.getProductOptions';
    import getColorsByProduct from '@salesforce/apex/TC_CPQColorController.getColorOptionsByProductCode';
    import getProductDetails from '@salesforce/apex/TC_CPQColorController.getProductDetails';
    import search from '@salesforce/apex/TC_CPQColorController.search';
    import hasCPQDebugPermission from '@salesforce/customPermission/CPQ_Debug';
    import {calculateMargin, calculateDiscount, getPricingUomCost, getPricingUomCustomerPrice, getPricingUomBookPrice} from 'c/tremcoUtils';//SSN-33
    
    export default class TcCPQQuoteLineEditorItem extends LightningElement {

        logDebug(...messages) {
            if (hasCPQDebugPermission) {
                //console.log(...messages);
            }
        }
    
        constructor() {
            super();
            // Initialize a flag to check if the user has stopped typing
            this.isTyping = false;
        }
    
        @api
        get showDisabled() {
            return this._showDisabled || this._item.hasErrors;
        }
        
        set showDisabled(value) {
            this._showDisabled = value;
        }
    
        get isColorDisabled() {
            // Check if colorOptions is an array and is empty
            const isColorOptionsEmpty = Array.isArray(this.colorOptions) && this.colorOptions.length === 0;
        
            return this._showDisabled || this._item.hasErrors || this.disableColorSelection || isColorOptionsEmpty;
        }
        //SSN-340-Aza
        get isQuantityDisabled() {
            //SSN-340-Aza
            return this.showUpdateDisabled || this._item?.hasErrors || this._item?.errorIsDiscontinued;
        }

        get priceWithTradeDiscount(){
            const tradeDiscountPercentage = parseFloat(this._item.tradeDiscountPercentage);
            if (!isNaN(this._item.salesUomPrice) && !isNaN(tradeDiscountPercentage)) {
                const discountAmount = this._item.salesUomPrice * (tradeDiscountPercentage / 100);
                return (this._item.salesUomPrice - discountAmount).toFixed(2);
            } else {
                return "0.00";
            }
        }
        
        get requestPriceWithTradeDiscount(){
            const tradeDiscountPercentage = parseFloat(this._item.tradeDiscountPercentage);
            if (!isNaN(this._item.price) && !isNaN(tradeDiscountPercentage)) {
                const discountAmount = this._item.price * (tradeDiscountPercentage / 100);
                return (this._item.price - discountAmount).toFixed(2);
            } else {
                return "0.00";
            }
        }
        
        get pricingPriceWithTradeDiscount(){
            const tradeDiscountPercentage = parseFloat(this._item.tradeDiscountPercentage);
            if (!isNaN(this._item.pricingUomPrice) && !isNaN(tradeDiscountPercentage)) {
                const discountAmount = this._item.pricingUomPrice * (tradeDiscountPercentage / 100);
                return (this._item.pricingUomPrice - discountAmount).toFixed(2);
            } else {
                return "0.00";
            }
        }
        
        get totalPriceWithTradeDiscount(){
            const tradeDiscountPercentage = parseFloat(this._item.tradeDiscountPercentage);
            if (!isNaN(this.lineTotal) && !isNaN(tradeDiscountPercentage)) {
                const discountAmount = this.lineTotal * (tradeDiscountPercentage / 100);
                return (this.lineTotal - discountAmount).toFixed(2);
            } else {
                return "0.00";
            }
        }
        

        get pricingUomBookPrice() {
            return getPricingUomBookPrice(this._item);//SSN-33
        }
        
        get pricingUomCustomerPrice() {
            return getPricingUomCustomerPrice(this._item, this.uomOptions);//SSN-33
        }

        /* Updated get pricingUomCost for SSN-33
        * If ConditionBaseValue <= 0 means, there is no book price for the product
        *   So, we have to calculate secondary UOM from the pricing factor
        * If ConditionBaseValue > 0 means, there is a book price for the product
        *   So, we can calculate secondary UOM by cost/ConditionBaseValue
        */
        get pricingUomCost() {
            return getPricingUomCost(this._item, this.uomOptions);//SSN-33      
        }

        /*get salesUomCost() {
            //cost is always in base uom so we just need to convert it to the sales uom
            const salesFactor = this.uomOptions.find(item => item.value === this._item.salesUom);
            console.log('this._item.cost'+this._item.cost);
            console.log('salesFactor.altQty'+salesFactor.altQty);
            console.log('salesFactor.baseQty'+salesFactor.baseQty);
            //return (this._item.cost * salesFactor.altQty * salesFactor.baseQty).toFixed(2); // commented out by Saha for SSN-33
            return (this._item.cost / salesFactor.altQty ).toFixed(2);
        }*/
        
        @api showUpdateDisabled;
        @track _item = {};
        @track initialProductSelection = [];
        @track errors = [];
        @track uomOptions = [];
        @track showSpinner = false;
        @track selectedProductCode;
        @track selectedColorCode;
        @track selectedColorId;   // SSN-231    
        @track dryvitOptions;
        @track colorOptions = [];
        @track initialColorSelection;
        @track disableColorSelection = true;
        isMultiEntry = false;
        newRecordOptions = [];
        minSearchTermLength = 2;
        searchTerm = '';
      
        @api hasApprover;
        isMultiEntry = false;
        newRecordOptions = [];
        minSearchTermLength = 2;
        searchTerm = '';
        selectedIds = [];
        prodList = [];
        _originalItem = {};
    
        get lineTotal() {
            return this._item.salesUomQty * this._item.salesUomPrice;
        }
        //SSN-316-Aza
        get hasMarginWarning() {
            const bookPrice = parseFloat(this._item?.bookPrice);
            const margin = parseFloat(this._item?.margin);
            return !isNaN(bookPrice) && bookPrice > 0 && !isNaN(margin) && margin <= 0;
        }
        //SSN-316-Aza
        get lineContainerClass() {
            let classes = 'slds-box slds-theme_default slds-var-m-top_small';
            if (this.hasMarginWarning) {
                classes += ' margin-warning-line';
            }
            return classes;
        }
        //SSN-5
        get isSapQuoteNumberPresent() {
            return this._item && this._item.sapQuoteNumber !== null && this._item.sapQuoteNumber !== '' && this._item.sapQuoteNumber !== undefined;
        }
        
        @api set item(value) {
            this._item = { ...value };
            // this.handleMargin();
        }
    
        get item() {
            return this._item;
        }
    
        connectedCallback() {
            this.handleDefaults();
            if (this._item.isDryvit) {
                getDryvitOptions()
                    .then(result => {
                        this.dryvitOptions = result;
                        // Check if dryvitProductCode is present when the line loads
                        if (this._item.dryvitProductCode) {
                            this.selectedProductCode = String(this._item.dryvitProductCode);
                            // Call getColorsByProduct to populate the colorOptions array
                            this.loadColorOptions();
                        } else{
                            this.initialColorSelection = [];
                        }
                    })
                    .catch(error => {
                        this.showToast('Error', 'Failed to retrieve Dryvit products.', 'error');
                        console.error(error);
                    });
            }
            //console.log('QuoteLineItem Object', this._item);
        }
    
        debounceTimer = null;
    
        handleFieldChange(event) {
            //console.log("handleFieldChange");
            clearTimeout(this.debounceTimer);
            this._item[event.currentTarget.dataset.id] = event.target.value;
            this.debounceTimer = setTimeout(() => {
                this.dispatchChangeEvent();
            }, 300); // Adjust the timeout duration as needed (300ms is a common choice)
        }
    
         // notify parent to delete line
         handleDelete() {
            // Emit the ondeleteitem event with the item's Id
            //console.log("Delete item " + this._item.Id, JSON.stringify(this._item));
            this.dispatchEvent(new CustomEvent('deleteitem', { detail: this._item.Id }));
        }
    
        handlePriceBlur(event){
            //console.log("priceBlur");
                const price = parseFloat(event.target.value);
                if (price <= 0) {
                    // Show toast message
                    this.showToast('Invalid Price', 'Price must be greater than zero.', 'error');
        
                    // Clear the input field
                    this._item.price = 0;
                }
                this.dispatchChangeEvent();
                    this.handleMargin('handlePriceBlur'); // Update the parent component
            }
    
            handleQtyBlur(event){
                //console.log('qtyblur');
                const qty = parseFloat(event.target.value);
                if (qty <= 0) {
                    // Show toast message
                    this.showToast('Invalid Qty', 'Qty must be greater than zero.', 'error');
        
                    // Clear the input field
                    this._item.qty = 1;
                } else{
                    this.dispatchChangeEvent();
                    this.handleMargin('handlePriceBlur'); // Update the parent component
                }
            }
    
            handleUOMChange(event){
                //console.log('handleUOMChange');
                clearTimeout(this.debounceTimer);
                this._item[event.currentTarget.dataset.id] = event.target.value;
                this.debounceTimer = setTimeout(() => {
                    this.dispatchChangeEvent();
                    this.handleMargin('handleUOMChange');
                }, 300);
            }
    
            showToast(title, message, variant) {
                const evt = new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: variant,
                });
                this.dispatchEvent(evt);
            }
    
        @api
        handleDefaults() {
            //console.log('==handleDefaults==');
            //console.log('this._item:', this._item);
    
            if (this._item.uomOptions) {
                this.uomOptions = JSON.parse(this._item.uomOptions);
            }

            //console.log('this.uomOptions:', this.uomOptions);
    
            if (this.uomOptions.length > 0) {
                if (this._item.pricingUom == null || this._item.pricingUom.trim() == '') {
                    if (this._item.uom != null) {
                        let tempArr = this.uomOptions.filter((item) => item.value == this._item.uom);
                        //console.log('tempArr (uom):', tempArr);
                        this.pricingUnit = tempArr[0].label;
                    }
                } else {
                    let tempArr = this.uomOptions.filter((item) => item.value == this._item.pricingUom);
                    this.pricingUnit = tempArr[0].label;
                }
            }
    
            if (!this._item.isApproved){
                this.showDisabled = false;
                this.showUpdateDisabled = false;
                this.handleMargin();
            } else {
            }
            //console.log('check to enable color selector for dryvit', this._item.dryvitProductCode, this._item.isApproved, this._item.showDisabled);
            if((this._item.dryvitProductCode != '' && this._item.dryvitProductCode != undefined) && this._item.isApproved == false && (this._item.showDisabled == false || this._item.showDisabled == undefined)){
                this.disableColorSelection = false;
                //console.log('EnableColorSelection isColorDisabled?', this.isColorDisabled );
            }
            this._originalItem = { ...this._item };
        }
    
        handleMargin() {
            // Check if there are errors or if essential fields are not defined
            if (this._item.hasErrors || this._item.baseUom === undefined || 
                !this._item.qty || !this._item.price || !this._item.uom) {
                return;
            }
    
            if (this._item.hasErrors || this._item.baseUom === undefined) {
                return;
            }
            
            if (this.uomOptions.length > 0 && this._item.product2 && this._item.account) {
                let requestFactor = this.uomOptions.find(item => item.value == this._item.uom);
                let salesFactor = this.uomOptions.find(item => item.value == this._item.salesUom);
                let pricingFactor = this.uomOptions.find(item => item.value == this._item.pricingUom);
        
                let baseQty = parseFloat(this._item.qty);
                let basePrice = parseFloat(this._item.price);
        
                //console.log(`%cBase Quantity: ${baseQty}, Base Price: ${basePrice}`, 'color: #39FF14;');
        
                if (this._item.uom != this._item.baseUom && requestFactor) {
                    //console.log('%cConverting request UOM to base UOM', 'color: #39FF14;');
                    baseQty = baseQty * requestFactor.baseQty / requestFactor.altQty;
                    //console.log(`%cConverted base quantity: ${baseQty}`, 'color: #39FF14;');
                }
        
                if (this._item.salesUom != this._item.baseUom && salesFactor) {
                    //console.log('%cConverting base UOM to sales UOM', 'color: #39FF14;');
                    this._item.salesUomQty = Math.ceil(baseQty * salesFactor.altQty / salesFactor.baseQty);
                } else {
                    this._item.salesUomQty = Math.ceil(baseQty);
                }
                //console.log(`%cSales Quantity: ${this._item.salesUomQty}`, 'color: #39FF14;');

                  // Check if minimum order quantity and increment are greater than zero
                    if (this._item.minimumOrderQty > 0) {
                        // Adjust for minimum order quantity
                        if (this._item.salesUomQty < this._item.minimumOrderQty) {
                            this._item.salesUomQty = this._item.minimumOrderQty;
                            this.showToast('Quantity Adjusted', `Sales quantity adjusted to minimum order quantity: ${this._item.minimumOrderQty}`, 'info');
                        }
                    }

                    if (this._item.increment > 0) {
                        // Ensure salesUomQty meets or exceeds the minimum order quantity.
                        if (this._item.salesUomQty < this._item.minimumOrderQty) {
                            this._item.salesUomQty = this._item.minimumOrderQty;
                            this.showToast('Quantity Adjusted', `Sales quantity adjusted to minimum order quantity: ${this._item.minimumOrderQty}`, 'info');
                        }
                    
                        // Directly check if salesUomQty is divisible by the increment from the get-go, without subtracting the minimumOrderQty.
                        let remainderFromStart = this._item.salesUomQty % this._item.increment;
                    
                        if (remainderFromStart !== 0 && this._item.salesUomQty >= this._item.minimumOrderQty) {
                            let additionalQtyNeeded = this._item.increment - remainderFromStart;
                            this._item.salesUomQty += additionalQtyNeeded;
                            this.showToast('Quantity Adjusted', `Sales quantity adjusted to align with increment. New quantity: ${this._item.salesUomQty}`, 'info');
                            console.log('Adjusted - Additional Qty Needed for Increment:', additionalQtyNeeded);
                            console.log('Adjusted - New salesUomQty after Increment Adjustment:', this._item.salesUomQty);
                        } else {
                            console.log('Adjusted - No adjustment needed for increment. salesUomQty already aligns with increment.');
                        }
                    }                   
        
                let baseUomPricePerUnit = basePrice * requestFactor.altQty / requestFactor.baseQty;
                this._item.baseUomPrice = baseUomPricePerUnit;
                // this._item.salesUomPrice = baseUomPricePerUnit;
                //console.log(`%cBase UOM Price Per Unit: ${baseUomPricePerUnit}`, 'color: #39FF14;');

                // Conversion from base UOM to sales UOM for pricing
                    if (this._item.salesUom != this._item.baseUom && salesFactor) {
                        // Adjust the base unit price per unit to the sales UOM
                        // This calculation depends on the specific conversion logic, assumed here as proportional conversion
                        let salesUomPricePerUnit = baseUomPricePerUnit * salesFactor.baseQty / salesFactor.altQty;
                        this._item.salesUomPrice = salesUomPricePerUnit;
                    } else {
                        // If salesUOM is the same as baseUOM, the price per unit remains unchanged
                        this._item.salesUomPrice = baseUomPricePerUnit;
                    }
        
                if (this._item.pricingUom != this._item.baseUom && pricingFactor) {
                    //console.log('%cConverting base UOM to pricing UOM', 'color: #39FF14;');
                    this._item.pricingUomPrice = baseUomPricePerUnit * pricingFactor.baseQty / pricingFactor.altQty;
                } else {
                    this._item.pricingUomPrice = baseUomPricePerUnit;
                }
                //console.log(`%cPricing UOM Price: ${this._item.pricingUomPrice}`, 'color: #39FF14;');
                

                if(this._item.price){
            
                    const pricingFactor = this.uomOptions.find(item => item.value === this._item.uom);
                    const salesFactor = this.uomOptions.find(item => item.value === this._item.salesUom);
                    
                    if (salesFactor && pricingFactor){
                        /** SSN-33 Discount Logic */
                        let tempbookPrice = Number(this._item.bookPrice * salesFactor.altQty / salesFactor.baseQty).toFixed(2);
                        let tempBookPricePerUnit = (tempbookPrice * pricingFactor.baseQty / pricingFactor.altQty).toFixed(2);
                        /* SSN-33 Added to fix -infinity discount value. Calling calculateDiscount method to calculate discount exclusively*/
                        this._item.discount = calculateDiscount(this._item.price, tempBookPricePerUnit, this._item.conditionBaseValue, this._item.uom, this._item.salesUom, this._item.pricingUom, this._item.bookPrice, this.pricingUomBookPrice);//SSN-33
                        //SSN-33 - this.calculateDiscount(this._item.price, tempBookPricePerUnit, this._item.ConditionBaseValue);
                        
                        /*** SSN-33 Margin Logic */
                        let tempCost =  (this._item.cost * salesFactor.altQty / salesFactor.baseQty).toFixed(2);
                        let baseUomPricePerUnit = (tempCost*pricingFactor.baseQty/pricingFactor.altQty).toFixed(2);
                        this._item.margin = calculateMargin(this._item.price, baseUomPricePerUnit);//SSN-33
                        //SSN-33 - this.calculateMargin(this._item.price, baseUomPricePerUnit);
                    }         
                }


                //this._item.margin = this.calculateMargin(baseUomPricePerUnit, this._item.cost);//commented out for SSN-33
                
                //console.log(`%cMargin: ${this._item.margin}`, 'color: #39FF14;');
        
                //this._item.discount = this.calculateDiscount(); //commented out for SSN-33
                //console.log(`%cDiscount: ${this._item.discount}`, 'color: #39FF14;');
    
                // Add this line to log the lineTotal
                //console.log(`%cLine Total: ${this.lineTotal}`, 'color: #39FF14;');
        
                this.checkForApproval();
                //console.log(`%cApproval Status: ${this._item.approvalStatus}, Approval Reason: ${this._item.approvalReason}`, 'color: #39FF14;');
    
            } else {
                //console.log('%chandleMargin skipped due to missing data', 'color: #39FF14;');
            }
        
            //console.log('%cEnding handleMargin function', 'color: #39FF14;');
        }
        /* Commenting out below methods for SSN-33 as logics has been moved to tremcoUtils.js
        calculateDiscount() {
            if (!this._item.bookPrice || this._item.bookPrice <= 0) {
                return 0;
            }
            const discount = (1 - (this._item.salesUomPrice / this._item.bookPrice)) * 100;
            return Number(discount.toFixed(3));
        }
        

        calculateMargin(pricePerUnit, costPerUnit) {
            if (!pricePerUnit || pricePerUnit <= 0) {
                return 0; // Handle edge case where price is zero or undefined
            }
            let margin = ((pricePerUnit - costPerUnit) / pricePerUnit) * 100;
            return isFinite(margin) ? margin.toFixed(2) : '0.00';
        }

        calculateDiscount(pricePerUnit, tempBookPricePerUnit, conditionBaseValue) {
            if (!pricePerUnit || pricePerUnit <= 0) {
                return 0;
            }
            let discount = (100 - (pricePerUnit / (this._item.uom == this._item.salesUom ? this._item.bookPrice : (this._item.uom == this._item.pricingUom ? this.pricingUomBookPrice : tempBookPricePerUnit)) * 100 ));   
            return isFinite(discount) && discount > 0 ? discount.toFixed(3) : '0.00';
        }    
    
        calculateMargin(pricePerUnit, costPerUnit) {
            if (!pricePerUnit || pricePerUnit <= 0) {
                return 0; // Handle edge case where price is zero or undefined
            }
            let margin = ((pricePerUnit - costPerUnit) / pricePerUnit) * 100;
            return isFinite(margin) && margin > 0 ? margin.toFixed(2) : '0.00';
        }*/
        
    
        checkForApproval() {
            // Skip logic if the approvalStatus is already "Approved"
            if (this._item.approvalStatus === 'Approved') {
                return;
            }
        
            if (this._item.discount > this._item.maxDiscount) {
                this._item.approvalStatus = 'Needs Approval';
                this._item.approvalReason = 'Excessive Discount Percentage';
            } else if (this._item.bookPrice === 0) {
                this._item.approvalStatus = 'Needs Approval';
                this._item.approvalReason = 'No Book Price';
            } else {
                this._item.approvalStatus = 'Auto-Approved';
                this._item.approvalReason = '';
            }
        }
        
    
        calculateSalesUomPrice(basePrice, baseQty, salesUomQty) {
            let totalBasePrice = basePrice * baseQty;
            return salesUomQty > 0 ? totalBasePrice / salesUomQty : 0;
        }
    
        @api
        handleReset() {
            this._item = { ...this._originalItem };
            this.handleCancel();
        }
    
        @api
        handleCancel() {
            this.template.querySelectorAll('c-lookup').forEach(element => {
                element.selection = this.initialProductSelection;
                if (this.initialProductSelection.length == 0) {
                    this.uomOptions = [];
                }
            });
        }
    
        handleClearPricing() {
            this._item.pricingUom = '';
            this._item.price = 0;
            this._item.pricingUomPrice = 0;
            this._item.salesUom = '';
            this._item.salesUomPrice = 0;
            this._item.baseUom = '';
            this._item.baseUomPrice = 0;
            this._item.bookPrice = 0;
            this._item.customerPrice = 0;
            this._item.discount = 0;
            this._item.tradeDiscount = 0;
            this._item.tradeDiscountPercentage = '';
            this._item.cost = 0;
            this.pricingUnit = '';
            this._item.isTradeDiscount = false;
            this._item.approvalStatus = '';
            this._item.approvalReason = '';
            this._item.minimumOrderQty = 0;
            this._item.increment = 0;
        }
    
        dispatchChangeEvent() {
            this.dispatchEvent(new CustomEvent('change', {
                detail: this._item
            }));
        }
    
        // Inside the child component JavaScript
    handleChildDragStart(event) {
        event.preventDefault();
        event.stopPropagation();
        // Add any additional logic you need here
    }
    
    
    handleProductChange(event) {
        this.initialColorSelection = [];
        this.resetItemAttributes();
        this.handleClearPricing();
        this.selectedProductCode = String(event.detail.value); // Ensure it's a string
        //console.log("Selected Product Code: " + this.selectedProductCode);
    
        // Call Apex to get colors based on the selected product
        getColorsByProduct({ colorCode: this.selectedProductCode })
            .then(result => {
                this.colorOptions = result;
                //console.log("colorOptions", this.colorOptions);
    
                // Check if the result is empty and show a toast message
                if (this.colorOptions.length === 0) {
                    this.showToast('Attention', 'No colors available for the selected product.', 'info');
                } else{
                    // Set these results in the child component
                this.setInitialResultsInChild(this.colorOptions);
                this.disableColorSelection = false;
                }
            })
            .catch(error => {
                this.showToast('Error', 'Failed to retrieve product colors.', 'error');
                console.error(error);
            });
    }
    
    
    setInitialResultsInChild(results) {
        // Get a reference to the child component
        const lookupComponent = this.template.querySelector('c-lookup'); // Replace 'c-lookup' with your child component's tag
    
        // Call setDefaultResults on the child component
        if (lookupComponent) {
            lookupComponent.setSearchResults(results);
        }
    }
    
    handleColorSearch(event) {
    
        const lookupElement = event.target;
        const searchTerm = event.detail.searchTerm;
            search({ searchTerm: searchTerm, selectedIds: this.selectedIds, finish: this.selectedProductCode }) 
            .then(data => {
                //console.log('Color LookupSearchResults: ', JSON.stringify(data));
                // Assign the results based on which lookup search is called
                lookupElement.setSearchResults(data);
            })
            .catch(error => {
                console.error('Error: ', JSON.stringify(error));
            });
    }
    
    
    handleColorChange(event) {
            const lookupElement = event.target;
            let selection = lookupElement.getSelection();
            if (selection.length === 0) {
                // User has cleared the selection. 
                //console.log('Selection cleared');
                this.resetItemAttributes();
                this.handleClearPricing();
                this.loadColorOptions(); // Reload color options as needed
                return; 
            }
            this.selectedColorId = selection[0].id;           // SSN-231    
            this.selectedColorCode = selection[0].subtitle;   // SSN-231    
            //console.log('Color Selection', selection, this.selectedProductCode, this.selectedColorCode);
    
        getProductDetails({ colorId: this.selectedColorId })
            .then(result => {
                // Integrate the product details into the data model
                this._item.product2 = result.id;
                this._item.materialNumber = result.stockkeepingUnit;
                this._item.productDetail = result.name;
                this._item.dryvitColorCode = this.selectedColorCode;  // SSN-231    
                this._item.dryvitColorId = this.selectedColorId;      // SSN-231    
                this._item.dryvitProductCode = this.selectedProductCode;
                this._item.uomOptions = result.processedAvailableUOM;
                this.uomOptions = JSON.parse(this._item.uomOptions);
                // call for pricing
                const pricingEvent = new CustomEvent('requestpricing', {
                    detail: this.item 
                });
                this.dispatchChangeEvent();
                this.dispatchEvent(pricingEvent);
            })
            .catch(error => {
                this.showToast('Error', 'Failed to retrieve product details.', 'error');
                this.initialColorSelection = [];
                getColorsByProduct({ colorCode: this.selectedProductCode })
                .then(result => {
                    this.colorOptions = result;
                    //console.log("colorOptions", this.colorOptions);
                    // Set these results in the child component
                    this.setInitialResultsInChild(this.colorOptions);
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to retrieve product colors.', 'error');
                    console.error(error);
                });
                console.error(error);
            });
        }
    
    // New method to load color options
    loadColorOptions() {
        //console.log("Getting colors for " + this.selectedProductCode);
        getColorsByProduct({ colorCode: String(this.selectedProductCode) })
            .then(result => {
                this.colorOptions = result;
                this.setInitialResultsInChild(this.colorOptions);
    
                // If dryvitColorCode is present, set the selectedColorCode
                if (this._item.dryvitColorCode) {
                    this.selectedColorCode = this._item.dryvitColorCode;
    
                    // Find and set the initial color selection
                    const initialColor = this.colorOptions.find(option => option.id === this._item.dryvitColorId);  // SSN-231    
                    if (initialColor) {
                        this.initialColorSelection = initialColor;
                    }
                }
    
                //console.log("loaded coloroptions onload ", this.colorOptions, this.selectedColorCode, this._item.dryvitColorCode, this.initialColorSelection,this._item.dryvitColorId);
            })
            .catch(error => {
                this.showToast('Error', 'Failed to retrieve product colors.', 'error');
                console.error(error);
            });
    }

    resetItemAttributes() {
        this._item.product2 = null;
        this._item.materialNumber = null;
        this._item.productDetail = null;
        this._item.dryvitColorCode = null;
        this._item.uomOptions = null;
        this.uomOptions = [];
    }
    
    
    }
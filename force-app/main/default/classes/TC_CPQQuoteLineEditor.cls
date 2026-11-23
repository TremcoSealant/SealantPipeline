public with sharing class TC_CPQQuoteLineEditor {
    // Global Defaults
    private final static String PRODUCT_ICON = 'standard:product';

    @AuraEnabled
    public static QuoteWrapper getQuoteLines(String recordId){
        // List<SBQQ__Quote__c> quoteList = [Select Id, ensxtx_SAP_Quote_Number__c, Open_for_Updates__c, SBQQ__EndDate__c, SBQQ__Account__c, SBQQ__Account__r.IsSoldTo__c, SBQQ__Status__c, (Select Id, ensxtx_Created_SAP_Item_Number__c, isApproved__c, Minimum_Order_Qty__c, Increment__c, isDryvit__c, Color_Code__c, Product_Code__c, Customer_Special_UOM__c, SBQQ__CustomerPrice__c, ApprovalStatus__c, MaximumDiscount__c, ApprovalReason__c, SBQQ__Quantity__c, Requested_Quantity__c, Requested_Price__c, SBQQ__StartDate__c, SBQQ__EndDate__c, UnitOfMeasure__c, Cost__c, CustomerPrice__c, Discount__c, SalesUOMPrice__c, Customer_Book_Price__c, IsTradeDiscount__c, TradeDiscount__c, SBQQ__ListPrice__c, Margin__c, Pricing_UOM_Price__c, Pricing_UOM__c, Pricing_UOM_Price_Placeholder__c, Pricing_UOM_Placeholder__c, Sales_UOM__c,SBQQ__Product__c, SBQQ__Product__r.Name,  SBQQ__Product__r.Description, SBQQ__Product__r.Material_Group_3__c, SBQQ__Product__r.Material_Price_Group__c, SBQQ__Product__r.StockKeepingUnit, SBQQ__Product__r.ProductCode, SBQQ__Product__r.Product_Group__c, SBQQ__Product__r.Margin_Minimum__c, SBQQ__Product__r.MaximumDiscount__c, SBQQ__Product__r.Available_UOM__c, SBQQ__UnitCost__c, BaseUOMPrice__c, BaseUOM__c, SBQQ__ProratedListPrice__c, SBQQ__RegularPrice__c, SBQQ__Number__c FROM SBQQ__LineItems__r ORDER BY SBQQ__Number__c asc) FROM SBQQ__Quote__c WHERE Id =: recordId];
        List<SBQQ__Quote__c> quoteList = [
            SELECT 
                Id, 
                ensxtx_SAP_Quote_Number__c, 
                Open_for_Updates__c, 
                SBQQ__EndDate__c, 
                SBQQ__Account__c, 
                SBQQ__Account__r.IsSoldTo__c,
                SBQQ__Account__r.Price_Group_Friendly__c, 
                SBQQ__Status__c, 
                (
                    SELECT 
                    Id, ensxtx_Created_SAP_Item_Number__c, isApproved__c, Minimum_Order_Qty__c, Increment__c, isDryvit__c, Color_Code__c, ColorId__c, Product_Code__c, Customer_Special_UOM__c, SBQQ__CustomerPrice__c, ApprovalStatus__c, MaximumDiscount__c, ApprovalReason__c, SBQQ__Quantity__c, Requested_Quantity__c, Requested_Price__c, SBQQ__StartDate__c, SBQQ__EndDate__c, UnitOfMeasure__c, Cost__c, CustomerPrice__c, Discount__c, SalesUOMPrice__c, Customer_Book_Price__c, IsTradeDiscount__c, TradeDiscount__c, SBQQ__ListPrice__c, Margin__c, Pricing_UOM_Price__c, Pricing_UOM__c, Pricing_UOM_Price_Placeholder__c, Pricing_UOM_Placeholder__c, Sales_UOM__c,SBQQ__Product__c, SBQQ__Product__r.Name,  SBQQ__Product__r.Description, SBQQ__Product__r.Material_Group_3__c, SBQQ__Product__r.Material_Price_Group__c, SBQQ__Product__r.StockKeepingUnit, SBQQ__Product__r.ProductCode, SBQQ__Product__r.Product_Group__c, SBQQ__Product__r.Margin_Minimum__c, SBQQ__Product__r.MaximumDiscount__c, SBQQ__Product__r.Available_UOM__c, SBQQ__UnitCost__c, BaseUOMPrice__c, BaseUOM__c, SBQQ__ProratedListPrice__c, SBQQ__RegularPrice__c, SBQQ__Number__c, 
                        SBQQ__Product__r.BAG_Alt_UOM_Qty__c, 
                        SBQQ__Product__r.BAG_Base_UOM_Qty__c, 
                        SBQQ__Product__r.BDL_Alt_UOM_Qty__c, 
                        SBQQ__Product__r.BDL_Base_UOM_Qty__c, 
                        SBQQ__Product__r.BF_Alt_UOM_Qty__c,
                        SBQQ__Product__r.BF_Base_UOM_Qty__c,
                        SBQQ__Product__r.CNT_Alt_UOM_Qty__c, 
                        SBQQ__Product__r.CNT_Base_UOM_Qty__c, 
                        SBQQ__Product__r.CR_Alt_UOM_Qty__c, 
                        SBQQ__Product__r.CR_Base_UOM_Qty__c, 
                        SBQQ__Product__r.CS_Alt_UOM_Qty__c, 
                        SBQQ__Product__r.CS_Base_UOM_Qty__c, 
                        SBQQ__Product__r.CTG_Alt_UOM_Qty__c, 
                        SBQQ__Product__r.CTG_Base_UOM_Qty__c,
                        SBQQ__Product__r.DRM_Alt_UOM_Qty__c, 
                        SBQQ__Product__r.DRM_Base_UOM_Qty__c, 
                        SBQQ__Product__r.EA_Alt_UOM_Qty__c,
                        SBQQ__Product__r.EA_Base_UOM_Qty__c,
                        SBQQ__Product__r.FT_Alt_UOM_Qty__c,
                        SBQQ__Product__r.FT_Base_UOM_Qty__c,
                        SBQQ__Product__r.FT2_Alt_UOM_Qty__c,
                        SBQQ__Product__r.FT2_Base_UOM_Qty__c,
                        SBQQ__Product__r.GAL_Alt_UOM_Qty__c,
                        SBQQ__Product__r.GAL_Base_UOM_Qty__c,
                        SBQQ__Product__r.KIT_Alt_UOM_Qty__c,
                        SBQQ__Product__r.KIT_Base_UOM_Qty__c,
                        SBQQ__Product__r.LB_Alt_UOM_Qty__c,
                        SBQQ__Product__r.LB_Base_UOM_Qty__c,
                        SBQQ__Product__r.PAL_Alt_UOM_Qty__c,
                        SBQQ__Product__r.PAL_Base_UOM_Qty__c,
                        SBQQ__Product__r.PCE_Alt_UOM_Qty__c,
                        SBQQ__Product__r.PCE_Base_UOM_Qty__c,
                        SBQQ__Product__r.ROL_Alt_UOM_Qty__c,
                        SBQQ__Product__r.ROL_Base_UOM_Qty__c,
                        SBQQ__Product__r.SSG_Alt_UOM_Qty__c,
                        SBQQ__Product__r.SSG_Base_UOM_Qty__c,
                        SBQQ__Product__r.L_Alt_UOM_Qty__c,
                        SBQQ__Product__r.L_Base_UOM_Qty__c,
                        SBQQ__Product__r.PAC_Alt_UOM_Qty__c,
                        SBQQ__Product__r.PAC_Base_UOM_Qty__c,
                        SBQQ__Product__r.PT_Alt_UOM_Qty__c,
                        SBQQ__Product__r.PT_Base_UOM_Qty__c,
                        ConditionBaseValue__c //SSN-33
                        FROM SBQQ__LineItems__r
                        ORDER BY SBQQ__Number__c ASC
                    )
                    FROM SBQQ__Quote__c
                    WHERE Id =: recordId
                    ];
                        
        
        List<String> materialList = new List<String>();
        Boolean callPricing = false;
        // get config 
        List<CustomerSpecial__mdt> csList = [SELECT Id,  Material_Exclusion_List__c FROM CustomerSpecial__mdt WHERE IsActive__c = true LIMIT 1];
        if(!csList.isEmpty()){
            if(csList[0].Material_Exclusion_List__c != null){
            materialList = csList[0].Material_Exclusion_List__c.split(',');
            }
        }
        QuoteWrapper quoteWrapper = new QuoteWrapper();
        
        if(!quoteList.isEmpty()){
            Integer i = 1;
            quoteWrapper.Id = recordId;
            quoteWrapper.sapQuoteNumber = quoteList[0]?.ensxtx_SAP_Quote_Number__c;
            quoteWrapper.quoteStatus = quoteList[0]?.SBQQ__Status__c;
            quoteWrapper.isSubmitted = (quoteList[0]?.SBQQ__Status__c != 'Draft' && quoteList[0]?.SBQQ__Status__c != 'Rejected') ? true : false;
            quoteWrapper.isAccepted = quoteList[0]?.SBQQ__Status__c == 'Accepted' || quoteList[0]?.Open_for_Updates__c == true;
            quoteWrapper.quoteAccountId = quoteList[0].SBQQ__Account__c;
            quoteWrapper.quoteEndDate = quoteList[0].SBQQ__EndDate__c;
            quoteWrapper.openForUpdates = quoteList[0].Open_for_Updates__c;
            List<SBQQ__QuoteLine__c> quoteLines = quoteList[0]?.SBQQ__LineItems__r;
            List<QuoteLineWrapper> quoteLineWrapperList = new List<QuoteLineWrapper>(); 
            for(SBQQ__QuoteLine__c quoteLine: quoteLines){
                if(quoteLine.Customer_Book_Price__c == null || quoteLine.CustomerPrice__c == null){
                    callPricing = true;
                }
                QuoteLineWrapper qLWrapper = new QuoteLineWrapper();
                Boolean isMatGroup = false; 
                if(quoteLine.SBQQ__Product__r.Material_Group_3__c != null && !materialList.contains(quoteLine.SBQQ__Product__r.Material_Group_3__c)){
                    isMatGroup = true;
                }else if(quoteLine.SBQQ__Product__r.Material_Price_Group__c != null && !materialList.contains(quoteLine.SBQQ__Product__r.Material_Price_Group__c)){
                    isMatGroup = true;
                }
                
                // String jsonString = quoteLine.SBQQ__Product__r.Available_UOM__c;
                String jsonString = TC_CPQUtils.generateUOMJson(quoteLine.SBQQ__Product__r);
                
                // Check if the first character after the opening bracket is a comma and remove it if so.
                if(jsonString != null && jsonString.length() > 2 && jsonString.substring(1, 2).equals(',')) {
                    jsonString = '[' + jsonString.substring(2);
                }

                String prodDetail = quoteLine.SBQQ__Product__r.Name;
                qLWrapper.productDetail = prodDetail;
                qLWrapper.recordId = quoteLine.Id;
                qLWrapper.account = quoteList[0]?.SBQQ__Account__c;
                qLWrapper.isSoldTo = quoteList[0]?.SBQQ__Account__r.IsSoldTo__c;
                qLWrapper.accountPriceGroup = quoteList[0]?.SBQQ__Account__r.Price_Group_Friendly__c;
                qLWrapper.Id = 'item' + i; 
                qLWrapper.product2 = quoteLine.SBQQ__Product__c;
                qLWrapper.price = quoteLine.Requested_Price__c;
                qLWrapper.lineNumber = i;
                qLWrapper.uom = quoteLine.UnitOfMeasure__c;
                qLWrapper.uomOptions = jsonString;
                qLWrapper.pricingUom = quoteLine.Pricing_Uom__c != null ? quoteLine.Pricing_Uom__c : quoteLine.Pricing_UOM_Placeholder__c;
                qLWrapper.pricingUomPrice = quoteLine.Pricing_Uom_Price__c != null ? quoteLine.Pricing_Uom_Price__c : quoteLine.Pricing_Uom_Price_Placeholder__c;
                qLWrapper.salesUom = quoteLine.Sales_UOM__c;
                qLWrapper.salesUomPrice = quoteLine.SalesUOMPrice__c;
                qLWrapper.bookPrice = quoteLine.Customer_Book_Price__c;
                qLWrapper.customerPrice = quoteLine.CustomerPrice__c;
                qLWrapper.discount = quoteLine.Discount__c;
                qLWrapper.maxDiscount = quoteLine.MaximumDiscount__c; 
                qLWrapper.tradeDiscount = quoteLine.TradeDiscount__c;
                qLWrapper.tradeDiscountPercentage = String.valueOf(quoteLine.TradeDiscount__c);
                qLWrapper.cost = quoteLine.Cost__c;
                qLWrapper.margin = quoteLine.Margin__c;
                qLWrapper.marginMin = quoteLine.SBQQ__Product__r.Margin_Minimum__c;
                qLWrapper.materialNumber = quoteLine.SBQQ__Product__r.ProductCode;
                qLWrapper.materialPriceGroup = quoteLine.SBQQ__Product__r.Material_Price_Group__c;
                qLWrapper.materialGroup3 = quoteLine.SBQQ__Product__r.Material_Group_3__c;
                qLWrapper.isTradeDiscount = quoteLine.IsTradeDiscount__c;
                qLWrapper.startDate = quoteLine.SBQQ__StartDate__c;
                qLWrapper.endDate = quoteLine.SBQQ__EndDate__c;
                qLWrapper.isMaterialGroup = isMatGroup;
                qLWrapper.qty = quoteLine.Requested_Quantity__c != null ? quoteLine.Requested_Quantity__c : quoteLine.SBQQ__Quantity__c;
                qlWrapper.salesUomQty = quoteLine.SBQQ__Quantity__c;
                qlWrapper.salesUomPrice = quoteLine.SBQQ__CustomerPrice__c;
                qlWrapper.approvalStatus = quoteLine.ApprovalStatus__c;
                qlWrapper.approvalReason = quoteLine.ApprovalReason__c;
                qLWrapper.baseUomPrice = quoteLine.BaseUOMPrice__c;
                qLWrapper.baseUom = quoteLine.BaseUOM__c;
                qlWrapper.cspUom = quoteLine.Customer_Special_UOM__c;
                qlWrapper.sortOrder = quoteLine.SBQQ__Number__c;
                qlWrapper.cspUom = quoteLine.Customer_Special_UOM__c;
                qlWrapper.dryvitColorCode = quoteLine.Color_Code__c;
                qlWrapper.dryvitColorId = quoteLine.ColorId__c;       // SSN-231         
                qlWrapper.dryvitProductCode = quoteLine.Product_Code__c;
                qlWrapper.isDryvit = quoteLine.isDryvit__c;
                qlWrapper.minimumOrderQty = quoteLine.Minimum_Order_Qty__c;
                qlWrapper.increment = quoteLine.Increment__c;
                qlWrapper.isApproved = quoteLine.isApproved__c;
                qlWrapper.sapItemNumber = quoteLine.ensxtx_Created_SAP_Item_Number__c;
                qlWrapper.sapQuoteNumber = quoteList[0]?.ensxtx_SAP_Quote_Number__c;
                qlWrapper.ConditionBaseValue = quoteLine.ConditionBaseValue__c;//SSN-33
                quoteLineWrapperList.add(qLWrapper);
                i++;
            }
            if(callPricing){
                //quoteLineWrapperList =  getPricing(null, quoteLineWrapperList);//SSN-33
            }
            quoteWrapper.quoteLines = quoteLineWrapperList;
        }
        return quoteWrapper;
    }

    /**
     * @description method to create customer special price requests/lines and submit for approval
     * @param  requestObj - wrapper object containing the quote and quoteline details
     * @return boolean - true if all operations were sucessful
     */
    @AuraEnabled
    public static Boolean updateQuoteLines(String requestObj, String[] deletedLines, Boolean submitForApproval, String initialApprovalComments){
        Boolean success = true;
        QuoteWrapper quoteWrap = (QuoteWrapper)JSON.deserialize(requestObj, QuoteWrapper.class);
        // System.debug(quoteWrap);      
        Boolean needsApproval = false;
        List<SBQQ__QuoteLine__c> quoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineListToInsert = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineWrapper line : quoteWrap.quoteLines){ 
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            if (line.approvalStatus != 'Approved') {
            if(line.discount > line.maxDiscount){
                needsApproval = true;
                quoteLine.ApprovalStatus__c = 'Needs Approval';
                quoteLine.ApprovalReason__c = 'Excessive Discount Percentage';
            }else if(line.bookPrice == 0){
                needsApproval = true;
                quoteLine.ApprovalStatus__c = 'Needs Approval';
                quoteLine.ApprovalReason__c = 'No Book Price';
            } else {
                quoteLine.ApprovalStatus__c = 'Auto-Approved';
                quoteLine.ApprovalReason__c = '';
            }
        }

            // quoteLine.Id = line.recordId;
            quoteLine.Requested_Price__c = line.price;
            quoteLine.Customer_Special_Price__c = line.customerPrice;
            quoteLine.UnitOfMeasure__c = line.uom;
            quoteLine.Request_UOM__c = line.uom;
            //only write to Pricing_Uom__c and Pricing_Uom_Price__c if Book Price is zero or if Book Price is greater than requested price.  Otherwise write to placeholder fields.
            // if(line.bookPrice == 0 || line.bookPrice > line.salesUomPrice){
            // quoteLine.Pricing_Uom__c = line.pricingUom;
            // quoteLine.Pricing_Uom_Price__c = line.pricingUomPrice;
            // } else {
            // quoteLine.Pricing_Uom_Placeholder__c = line.pricingUom;
            // quoteLine.Pricing_Uom_Price_Placeholder__c = line.pricingUomPrice;
            // }

                quoteLine.Pricing_Uom__c = line.pricingUom;
                quoteLine.Pricing_Uom_Price__c = line.pricingUomPrice;

                quoteLine.Pricing_Uom_Placeholder__c = line.pricingUom;
                quoteLine.Pricing_Uom_Price_Placeholder__c = line.pricingUomPrice;

            quoteLine.Sales_UOM__c = line.salesUom;
            quoteLine.SalesUOMPrice__c = line.salesUomPrice;
            quoteLine.Customer_Book_Price__c = line.bookPrice;
            quoteLine.CustomerPrice__c = line.customerPrice;
            quoteLine.Discount__c = line.discount;
            quoteLine.TradeDiscount__c = Decimal.valueOf(line.tradeDiscountPercentage);
            quoteLine.Cost__c = line.cost;
            quoteLine.SBQQ__UnitCost__c = line.cost;
            quoteLine.Margin__c = line.margin;
            quoteLine.IsTradeDiscount__c = line.isTradeDiscount;
            quoteLine.BaseUOMPrice__c = line.baseUomPrice;
            quoteLine.BaseUOM__c = line.baseUom;
            quoteLine.Customer_Special_UOM__c = line.cspUom;
            quoteLine.Requested_Quantity__c = line.qty;
            quoteLine.SBQQ__Quantity__c = line.salesUomQty;
            quoteLine.SBQQ__ListPrice__c = line.bookPrice > 0 ? line.bookPrice : line.salesUomPrice;
            quoteLine.SBQQ__RegularPrice__c = line.bookPrice > 0 ? line.bookPrice : line.salesUomPrice;
            quoteLine.SBQQ__CustomerPrice__c = line.salesUomPrice;
            quoteLine.SBQQ__AdditionalDiscountAmount__c = ((line.bookPrice > 0 ? line.bookPrice : line.salesUomPrice) - line.salesUomPrice);
            quoteLine.SBQQ__NetPrice__c = line.salesUomPrice;
            quoteLine.SBQQ__ProratedListPrice__c = line.bookPrice > 0 ? line.bookPrice : line.salesUomPrice;
            quoteLine.SBQQ__Number__c = line.sortOrder;
            quoteLine.Customer_Special_UOM__c = line.cspUom;
            quoteLine.Color_Code__c = line.dryvitColorCode;
            quoteLine.ColorId__c = line.dryvitColorId;   // SSN-231
            quoteLine.Product_Code__c = line.dryvitProductCode;
            quoteLine.isDryvit__c = line.isDryvit;
            quoteLine.ConditionBaseValue__c = line.ConditionBaseValue;//SSN-33
            quoteLine.ensxtx_SAP_Simulation_Error__c = getSimulationErrorMessage(line); //SSN-340-Aza
            //quoteLine.SBQQ__StartDate__c = line.startDate;
            //quoteLine.SBQQ__EndDate__c = line.endDate;
            // System.debug('Sales Quantity ' + line.salesUomQty);
            if (String.isBlank(line.recordId)) {
                // New line to be inserted
                quoteLine.SBQQ__Quote__c = quoteWrap.id;
                quoteLine.SBQQ__Product__c = line.product2;
                quoteLineListToInsert.add(quoteLine);
            } else {
                // Existing line to be updated
                quoteLine.Id = line.recordId;
                quoteLineListToUpdate.add(quoteLine);
            }
        }

        //Handle Deleted Lines  
        List<SBQQ__QuoteLine__c> deletedQuoteLines = new List<SBQQ__QuoteLine__c>();
        if(!deletedLines.isEmpty()){
            for(String delLine : deletedLines){
                SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(Id=delLine);
                deletedQuoteLines.add(line);
            }
        }

        SBQQ__Quote__c thisQuote = [
            SELECT 
                OwnerId, 
                SBQQ__SalesRep__c,
                SBQQ__EndDate__c,
                Initial_Approval__c,
                Second_Approval__c 
            FROM SBQQ__Quote__c 
            WHERE Id = :quoteWrap.id 
            LIMIT 1
        ];
        
        if (thisQuote != null) {
            // Query the Owner's ManagerId and Manager's ManagerId
            User ownerUser = [SELECT ManagerId, Manager.ManagerId FROM User WHERE Id = :thisQuote.OwnerId LIMIT 1];
        
            Id secondLevelApproverId = null;
            Id thirdLevelApproverId = null;
        
            if (ownerUser != null) {
                secondLevelApproverId = ownerUser.ManagerId;
                thirdLevelApproverId = (ownerUser.Manager != null) ? ownerUser.Manager.ManagerId : null;
            }
        
            // Check if Sales Rep exists and query their ManagerId and Manager's ManagerId
            if (thisQuote.SBQQ__SalesRep__c != null) {
                User salesRepUser = [SELECT ManagerId, Manager.ManagerId FROM User WHERE Id = :thisQuote.SBQQ__SalesRep__c LIMIT 1];
                if (salesRepUser != null) {
                    secondLevelApproverId = salesRepUser.ManagerId != null ? salesRepUser.ManagerId : secondLevelApproverId;
                    thirdLevelApproverId = (salesRepUser.Manager != null && salesRepUser.Manager.ManagerId != null) ? salesRepUser.Manager.ManagerId : thirdLevelApproverId;
                }
            }

            // Check to see if this is an update and the date is being extended further than 30 days. If so, require approval.
            if (thisQuote.Initial_Approval__c == true) {
                Integer daysExtended = quoteWrap.quoteEndDate.daysBetween(thisQuote.SBQQ__EndDate__c);
                if (daysExtended > 30) {
                    needsApproval = true;
                }
            }

            


            // Set End Date
            thisQuote.SBQQ__EndDate__c = quoteWrap.quoteEndDate;
        
            // Set the approver fields on the quote record
            thisQuote.Second_Level_Approver__c = secondLevelApproverId;
            thisQuote.Third_Level_Approver__c = thirdLevelApproverId;

            if(submitForApproval){
            thisQuote.Requires_Approval__c = needsApproval ? true : false;
            }

            thisQuote.Open_for_Updates__c = !submitForApproval && quoteWrap.openForUpdates;
            thisQuote.SBQQ__Status__c = (!submitForApproval && quoteWrap.openForUpdates) ? 'Draft' : quoteWrap.quoteStatus;

            // Perform the update operation
            update thisQuote;
        }
        



        Savepoint sp = Database.setSavepoint();

        try{
            if (!quoteLineListToUpdate.isEmpty()) {
                update quoteLineListToUpdate;
            }
            if (!quoteLineListToInsert.isEmpty()) {
                insert quoteLineListToInsert;
            }
            update thisQuote;
            if(!deletedQuoteLines.isEmpty()){
                delete deletedQuoteLines;
            }

            
        }catch(exception ex){
            Database.rollback(sp);
            System.debug('Exception: ' + ex.getMessage());
            success = false;
            throw new AuraHandledException('Error updating records: ' + ex.getMessage());
        }

        if(submitForApproval){
            // Assuming you have the ID of the SBQQ__Quote__c record
            Id quoteId = quoteWrap.id;
    
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments(initialApprovalComments);
            approvalRequest.setObjectId(quoteId);
    
            // Set the submitter ID to the current user
            Id currentUserId = UserInfo.getUserId();
            approvalRequest.setSubmitterId(currentUserId);
    
            try {
                // Submit the approval request
                Approval.ProcessResult result = Approval.process(approvalRequest);
                // Optional: Handle the result as needed
            } catch (Exception ex) {
                Database.rollback(sp);
                System.debug('Approval Exception: ' + ex.getMessage());
                success = false;
                throw new AuraHandledException('Error updating and submitting quote for approval: ' + ex.getMessage());
            }
        }

        return success;
    }
    //SSN-340-Aza Added method to get simulation error message for quote line
    private static String getSimulationErrorMessage(QuoteLineWrapper line) {
        if (line == null) {
            return null;
        }
        if (line.errorIsDiscontinued == true) {
            return 'Discontd w/o Replace';
        }
        if (line.hasErrors != true) {
            return null;
        }
        if (line.errorNotListed == true) {
            return 'is not listed and therefore not allowed';
        }
        if (line.errorIsExcluded == true) {
            return 'has been excluded';
        }
        if (line.errorNotInSAP == true) {
            return 'was not found';
        }
        if (line.errorNotIn2000 == true) {
            return 'is not defined for sales org 2000';
        }
        if (line.errorNotIn4000 == true) {
            return 'is not defined for sales org 4000';
        }
        if (line.errorIsBlocked == true) {
            return 'Blocked';
        }
        if (line.errorNullResponse == true) {
            return 'SAP pricing simulation returned no response';
        }
        return null;
    }

    /**
     * @description method to call the enosix api and get pricing from SAP
     * @param  quoteLines - quoteline item with account/product info
     * @return List<QuoteLineWrapper> - wrapper object containing the lines with pricing
     */
    @AuraEnabled
    public static List<QuoteLineWrapper> getPricing(String quoteLines, List<QuoteLineWrapper> lineWrapper){    
        // System.debug(quoteLines);
        String quoteAccountId = '';
        List<QuoteLineWrapper> quoteLineWrapper = new List<QuoteLineWrapper>();
        if(quoteLines == null){
            quoteLineWrapper = lineWrapper;
        }else{
             quoteLineWrapper = (List<QuoteLineWrapper>)JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class); 
        }
        List<QuoteLineWrapper> quoteLineList = new List<QuoteLineWrapper>();
        // System.debug(quoteLineWrapper);
        if(!quoteLineWrapper.isEmpty()){
            String pdpAppSettingsName = 'ensxtx_SR_enosixCartPDPAppSettings';
            String appSettingsName = 'ensxtx_SR_enosixProductB2BAppSettings';
            List<String> productInfoList = new List<String>();
            List<String> productIdList = new List<String>();
            Map<String,QuoteLineWrapper> quoteMap = new Map<String,QuoteLineWrapper>();
            Map<String, Id> sfObjectIdMap = new Map<String, Id>();
            String testProdId = '';
            
            for(QuoteLineWrapper quoteLine : quoteLineWrapper){
                String accId = quoteLine.account;
                String prodId = quoteLine.product2;
                testProdId = prodId;
                Decimal qty = quoteLine.salesUomQty != null ? quoteLine.salesUomQty : 1;
                if(accId != null && prodId != null){
                    quoteMap.put(prodId,quoteLine);
                    productIdList.add(prodId);
                    productInfoList.add(JSON.serialize(new Map<String, Object>{
                        'prodId' => prodId,
                        'quantity' => 1}));
                    sfObjectIdMap.put('ACCOUNT',accId);
                    quoteAccountId = quoteLine.account;
                }
            }
      
           
            try{ 
                ensxtx_UTIL_Aura.Response response;
                ensxtx_DS_Document_Detail salesDocDetail = new ensxtx_DS_Document_Detail();
                if(Test.isRunningTest()){
                    String jsonResponse = constructTestJsonResponse(testProdId);
                    SalesDocDetail = (ensxtx_DS_Document_Detail)JSON.deserialize(jsonResponse, ensxtx_DS_Document_Detail.class); 
                } else {
                response = ensxtx_CTRL_Cart.productSimulation(productInfoList, sfObjectIdMap, pdpAppSettingsName, appSettingsName);
                // System.debug('Full Response from Enosix '+JSON.serializePretty(response));
                salesDocDetail = (ensxtx_DS_Document_Detail)response.data;
                // System.debug('Doc Detail ' + salesDocDetail);
                }

                if (salesDocDetail == null) {
                    // Handle the case when salesDocDetail is null
                    for (QuoteLineWrapper quoteLine : quoteLineWrapper) {
                        // Update the quoteLine with the error information
                        quoteLine.entireAPIResponseWrapper = response; // Store the entire API response
                        quoteLine.hasErrors = true;
                        quoteLine.errorNullResponse = true;
                        // Modifications are automatically reflected in quoteLineWrapper
                    }
                    return quoteLineWrapper;
                } else {
                    if(salesDocDetail.IsSuccess){
                        Integer i = 0;
                        for(ensxtx_DS_Document_Detail.ITEMS item : salesDocDetail.ITEMS){
                            if(item.ProductId != null){
                                QuoteLineWrapper qLine = processItem(item, quoteMap, quoteAccountId);
                                quoteLineList.add(qLine);  
                            }
                        }
                    }else {
                        for (ensxtx_DS_Document_Detail.ITEMS item : salesDocDetail.ITEMS) {
                            if (item.ProductId != null) {
                                QuoteLineWrapper qLine = quoteMap.get(item.ProductId);
                        
                                // Handle specific error conditions
                                for (ensxtx_SAP_Transact_Log__c log : salesDocDetail.TransactLogs) {
                                    // System.debug('Current Log Message: ' + log.ensxtx_Message__c); 
                                    // Initialize component error states
                                    if (qLine.errorIsExcluded == null) qLine.errorIsExcluded = false;
                                    if (qLine.errorNotListed == null) qLine.errorNotListed = false;
                                    if (qLine.errorNotInSAP == null) qLine.errorNotInSAP = false;
                                    if (qLine.errorNotIn2000 == null) qLine.errorNotIn2000 = false;
                                    if (qLine.errorNotIn4000 == null) qLine.errorNotIn4000 = false;
                                    if (qLine.errorIsDiscontinued == null) qLine.errorIsDiscontinued = false;
                                    if (qLine.errorIsBlocked == null) qLine.errorIsBlocked = false;
                    
                                    if (log.ensxtx_Message__c.contains('is not listed and therefore not allowed')) {
                                        qLine.errorNotListed = true;
                                    } else if (log.ensxtx_Message__c.contains('has been excluded')) { 
                                        qLine.errorIsExcluded = true;
                                    } else if (log.ensxtx_Message__c.contains('was not found')) { 
                                        qLine.errorNotInSAP = true;
                                    } else if (log.ensxtx_Message__c.contains('is not defined for sales org') && log.ensxtx_Message__c.contains('2000')) { 
                                        qLine.errorNotIn2000 = true;
                                    } else if (log.ensxtx_Message__c.contains('is not defined for sales org') && log.ensxtx_Message__c.contains('4000')) { 
                                        qLine.errorNotIn4000 = true;
                                    } else if (log.ensxtx_Message__c.contains('Discontd w/o Replace')) { 
                                        qLine.errorIsDiscontinued = true;
                                    } else if (log.ensxtx_Message__c.contains('Blocked')) { 
                                        qLine.errorIsBlocked = true;
                                    } 
                                }
                                // Set hasErrors if any error property is true
                                qLine.hasErrors = qLine.errorNotListed || qLine.errorIsExcluded || qLine.errorNotInSAP || qLine.errorNotIn2000 || qLine.errorNotIn4000 || qLine.errorIsDiscontinued || qLine.errorIsBlocked;
                    
                                // Process the item using the common method
                                qLine = processItem(item, quoteMap, quoteAccountId);
                                quoteLineList.add(qLine);
                            }
                        }
                    }
                    
                    
                }
                    
            }catch(exception ex){
                System.debug('Exception ' + ex.getMessage());
                // throw new AuraHandledException('Error retrieving pricing');
            }
        }

    //    System.debug(quoteLineList);
       return quoteLineList;
    }

    private static QuoteLineWrapper processItem(ensxtx_DS_Document_Detail.ITEMS item, Map<String, QuoteLineWrapper> quoteMap, String quoteAccountId) {
        QuoteLineWrapper qLine = quoteMap.get(item.ProductId);
    
        // Initialize component error states
        if (qLine.errorIsExcluded == null) qLine.errorIsExcluded = false;
        if (qLine.errorNotListed == null) qLine.errorNotListed = false;
        if (qLine.errorNotInSAP == null) qLine.errorNotInSAP = false;
        if (qLine.errorNotIn2000 == null) qLine.errorNotIn2000 = false;
        if (qLine.errorNotIn4000 == null) qLine.errorNotIn4000 = false;
        if (qLine.errorIsDiscontinued == null) qLine.errorIsDiscontinued = false;
        if (qLine.errorIsBlocked == null) qLine.errorIsBlocked = false;
    
        // Set pricing and unit of measure details
        Decimal bkPrice = item.CustomerBookPrice / item.OrderQuantity;
        Decimal custPrice = item.CustomerSpecialPrice;
        qLine.pricingUom = item.ConditionUnitInternal; 
        qLine.pricingUomPrice = qLine.pricingUomPrice != null ? qLine.pricingUomPrice : 0.00;
        qLine.bookPrice = bkPrice.setScale(2, RoundingMode.HALF_UP); // in Sales UOM
        qLine.salesUom = item.SalesUnitInternal;
        qLine.baseUom = item.BaseUnitOfMeasureInternal;
        qLine.cspUom = item.BaseUnitOfMeasureInternal;
        qLine.uom = qLine.uom != null ? qLine.uom : item.SalesUnitInternal; // default uom to sales unit when not already set
        qLine.customerPrice = custPrice.setScale(2, RoundingMode.HALF_UP);
        qLine.tradeDiscount = item.Discounts;
        qLine.isTradeDiscount = item.Discounts != 0;
        qLine.maxDiscount = TC_CPQUtils.getDiscountThreshold(quoteAccountId, 'job', item.ProductId);
        System.debug('item.ConditionBaseValue : ' + item.ConditionBaseValue);
        qLine.ConditionBaseValue = item.ConditionBaseValue;//SSN-33

        // Calculate trade discount percentage
        Decimal tradeDiscountPercentage = 0;
        if (item.CustomerSpecialPrice > 0) {
            tradeDiscountPercentage = Math.abs(qLine.tradeDiscount / item.CustomerSpecialPrice) * 100;
        } else if (qLine.bookPrice > 0) {
            tradeDiscountPercentage = Math.abs(qLine.tradeDiscount / qLine.bookPrice) * 100;
        }
        // Convert trade discount percentage to String and round off to 2 decimal places
        qLine.tradeDiscountPercentage = tradeDiscountPercentage.setScale(2, RoundingMode.HALF_UP).toPlainString();
    
        // Process item conditions
        for(ensxtx_DS_Document_Detail.CONDITIONS condition : item.SBOItemConditions) {
            if(condition.ConditionType == 'VPRS') {
                // Decimal costValue = condition.ConditionValue != null ? condition.ConditionValue.setScale(2, RoundingMode.HALF_UP) : null;
                // Decimal costValue = (condition.Rate / condition.ConditionPricingUnit).setScale(2, RoundingMode.HALF_UP);
                qLine.cost = condition.ConditionValue;
                qLine.cur = condition.CurrencyKey;
            }
        }
    
        return qLine;
    }

    private static String constructTestJsonResponse(String testProdId) {
        return '{' +
        '"SFId": "01tDR00000HRvReYAL",' +
        '"SalesDocument": "SampleSalesDocument",' +
        '"SoldToParty": "6059064",' +
        '"SoldToPartyText": "NATIONAL WATERPROOFING",' +
        '"CustomerPurchaseOrderNumber": "Product",' +
        '"CustomerPurchaseOrderDate": "2024-01-20",' +
        '"NetOrderValue": 103.8,' +
        '"TaxAmount": 7.27,' +
        '"SalesDocumentCurrency": "USD",' +
        '"IsSuccess": true,' +
        '"isIncomplete": false,' +
        '"SALES": {' +
            '"SalesDocumentType": "OR",' +
            '"SalesOrganization": "2000",' +
            '"DistributionChannel": "30",' +
            '"Division": "30",' +
            '"CreateDate": "2024-01-20",' +
            '"RequestedDeliveryDate": "2024-01-20"' +
        '},' +
        '"PARTNERS": [' +
            '{"PartnerFunction": "SP", "CustomerNumber": "6059064"}' +
        '],' +
        '"CONDITIONS": [' +
            '{"ConditionType": "ZPRN", "ConditionValue": 144.9}' +
        '],' +
        '"TEXTS": [' +
            '{"TextID": "001", "Text": "Sample text"}' +
        '],' +
        '"ITEMS": [' +
            '{' +
                '"SFId": "01tDR00000HRvReYAL",' +
                '"ProductId": "' + testProdId + '",' +
                '"ItemNumber": "000010",' +
                '"OrderQuantity": 1,' +
                '"SalesUnit": "CS",' +
                '"CustomerSpecialPrice": 10,' +
                '"CustomerBookPrice": 10,' +
                '"ConditionUnitInternal": "CS",' +
                '"SalesUnitInternal": "CS",' +
                '"BaseUnitOfMeasureInternal": "CS",' +
                '"Discounts": 0,' +
                '"Plant": "MAME",' +
                '"NetItemPrice": 6.92,' +
                '"NetOrderValue": 103.8,' +
                '"NetWeight": 34,' +
                '"GrossWeight": 34,' +
                '"BaseUnitOfMeasure": "CS",' +
                '"AlternativeItem": "000000",' +
                '"ItemDescription": "DYMONIC 100 ALMOND -15X600ML SSG CS",' +
                '"ItemCategory": "TAN",' +
                '"isNeedConfigure": false,' +
                '"ItemSchedules": [' +
                    '{"ScheduleLineDate": "2024-02-02", "ConfirmedQuantity": 1}' +
                '],' +
                '"SBOItemConditions": [' +
                    '{"ConditionType": "VPRS", "ConditionValue": 144.9, "CurrencyKey": "USD"}' +
                ']' +
            '}' +
        '],' +
        '"IncompletionLogs": [' +
            '{"TextID": "001", "Text": "Incomplete item"}' +
        '],' +
        '"TransactLogs": [' +
            '{"ensxtx_Message__c": "Transaction log message"}' +
        ']' +
    '}';
    }
    


    /**
     * @description method to get the current step of the approval process and appovers
     * @param  userId - Id of the current user
     * @param recordId - Id of the current record
     * @return ApproverWrapper - wrapper object containing if the current user is an approver and the approval step Id
     */
    @AuraEnabled(cacheable=true)
    public static ApproverWrapper getApprover(String userId, String recordId){
        ApproverWrapper appWrapper = new ApproverWrapper();
        appWrapper.isApprover = false;
        List<String> approvers = new List<String>();
        List<String> groupList = new List<String>();
        String recId;
        
        List<ProcessInstance> processList = [SELECT CompletedDate, CreatedById, CreatedDate,Id,IsDeleted,LastActorId,LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById
                                            ,SystemModstamp,TargetObjectId, (SELECT ID, ProcessNodeId, StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending,OriginalActorId,ProcessInstanceId,RemindersSent,
                                            CreatedDate FROM StepsAndWorkitems WHERE IsPending = true) FROM ProcessInstance where ProcessInstance.TargetObjectId = :recordId];
        if(!processList.isEmpty()){
            for(ProcessInstance pr :  processList){
                for(ProcessInstanceHistory  step : pr.StepsAndWorkitems) {
                    recId = step.Id;
                    String user = step.ActorId;
                    if(user.startsWith('00G')){
                        groupList.add(user);
                    }else{
                        approvers.add(user);
                    }
                }
            }

            if(!groupList.isEmpty()){
                List<GroupMember> groupMemberList = [SELECT Id, GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId IN :groupList];
                for(GroupMember member : groupMemberList){
                    String user = member.UserOrGroupId;
                    approvers.add(user);
                }
            }

            if(approvers.contains(userId)){
                appWrapper.isApprover = true;
            } 
        }
        appWrapper.stepId = recId;
        return appWrapper;
    }

    public class QuoteWrapper {
        @AuraEnabled
        public String id {get;set;} 
        @AuraEnabled
        public Boolean isSubmitted {get;set;}
        @AuraEnabled
        public Boolean isAccepted {get;set;}
        @AuraEnabled
        public Boolean initialApprovalSuccessful {get;set;}
        @AuraEnabled
        public Boolean secondApprovalSuccessful {get;set;}
        @AuraEnabled
        public Boolean lineItemAdded {get;set;}
        @AuraEnabled
        public List<QuoteLineWrapper> quoteLines {get;set;} 
        @AuraEnabled
        public String quoteAccountId {get;set;}
        @AuraEnabled
        public Date quoteEndDate {get;set;}
        @AuraEnabled
        public Boolean openForUpdates {get;set;}
        @AuraEnabled
        public String quoteStatus {get;set;}
        @AuraEnabled
        public String sapQuoteNumber {get;set;}
        
    }

    public class QuoteLineWrapper {
        @AuraEnabled
        public String recordId {get;set;}
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String account {get;set;}
        @AuraEnabled
        public String accountDetail {get;set;}
        @AuraEnabled
        public Boolean isSoldTo {get;set;}  
        @AuraEnabled
        public String product2 {get;set;}
        @AuraEnabled
        public String productDetail {get;set;}
        @AuraEnabled  
        public String materialNumber {get;set;}
        @AuraEnabled  
        public String materialPriceGroup {get;set;}
        @AuraEnabled  
        public String materialGroup3 {get;set;}
        @AuraEnabled
        public Decimal price {get;set;}
        @AuraEnabled
        public Decimal pricingUomPrice {get;set;}
        @AuraEnabled
        public Decimal bookPrice {get;set;}
        @AuraEnabled
        public Decimal customerPrice {get;set;}
        @AuraEnabled
        public Decimal discount {get;set;}
        @AuraEnabled
        public Decimal maxDiscount {get;set;}
        @AuraEnabled
        public Decimal tradeDiscount {get;set;}
        @AuraEnabled
        public Decimal cost {get;set;}
        @AuraEnabled
        public Decimal margin {get;set;}
        @AuraEnabled
        public Decimal marginMin {get;set;}
        @AuraEnabled
        public String uom {get;set;}
        @AuraEnabled
        public String uomOptions {get;set;}
        @AuraEnabled
        public String salesUom {get;set;}
        @AuraEnabled
        public Decimal salesUomPrice {get;set;}
        @AuraEnabled
        public Decimal salesUomQty {get;set;}
        @AuraEnabled
        public String baseUom {get;set;}
        @AuraEnabled
        public Decimal baseUomPrice {get;set;}
        @AuraEnabled
        public Decimal qty {get;set;}
        @AuraEnabled
        public String pricingUom {get;set;}
        @AuraEnabled
        public Decimal lineNumber {get;set;}
        @AuraEnabled
        public Date startDate {get;set;}
        @AuraEnabled
        public Date endDate {get;set;}
        @AuraEnabled
        public Boolean isTradeDiscount {get;set;}
        @AuraEnabled
        public Boolean isMaterialGroup {get;set;}
        @AuraEnabled
        public String approvalStatus{get;set;}
        @AuraEnabled
        public String approvalReason {get;set;}
        @AuraEnabled
        public String cur {get;set;}
        @AuraEnabled
        public String tradeDiscountPercentage { get; set; }
        @AuraEnabled
        public Boolean hasErrors { get; set; }
        @AuraEnabled
        public Boolean errorIsExcluded { get; set; }
        @AuraEnabled
        public Boolean errorNotListed { get; set; }
        @AuraEnabled
        public Boolean errorNotInSAP { get; set; }
        @AuraEnabled
        public Boolean errorNotIn2000 { get; set; }
        @AuraEnabled
        public Boolean errorNotIn4000 { get; set; }
        @AuraEnabled
        public Boolean errorIsDiscontinued { get; set; }
        @AuraEnabled
        public Boolean errorIsBlocked { get; set; }
        @AuraEnabled
        public Boolean errorNullResponse { get; set; }
        @AuraEnabled 
        public Decimal sortOrder { get; set; }
        @AuraEnabled 
        public ensxtx_DS_Document_Detail entireAPIResponse { get; set; }
        @AuraEnabled
        public Object entireAPIResponseWrapper { get; set; }
        @AuraEnabled
        public Boolean isDryvit { get; set; }
        @AuraEnabled
        public String cspUom { get; set; }
        @AuraEnabled
        public String dryvitColorCode {get; set; }
        @AuraEnabled
        public String dryvitColorId {get; set; }  // SSN-231 
        @AuraEnabled
        public String dryvitProductCode {get; set; }
        @AuraEnabled
        public Decimal minimumOrderQty {get; set; }
        @AuraEnabled
        public Decimal increment {get; set; }
        @AuraEnabled
        public Boolean isApproved {get; set; }
        @AuraEnabled
        public String sapItemNumber {get; set; }
        @AuraEnabled
        public Decimal remainingQty {get; set; }
        @AuraEnabled
        public String accountPriceGroup {get; set; }
        @AuraEnabled
        public String sapQuoteNumber { get; set; }
        @AuraEnabled 
        public Decimal ConditionBaseValue { get; set; } // Added by Saha for SSN-33
     }

    public class ApproverWrapper{
        @AuraEnabled
        public Boolean isApprover {get;set;} 
        @AuraEnabled
        public String stepId {get;set;} 
    }
}
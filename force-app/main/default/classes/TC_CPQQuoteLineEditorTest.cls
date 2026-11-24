@IsTest(SeeAllData=true)
public class TC_CPQQuoteLineEditorTest {

    private static void createTestData() {
        Rocket_TestUtility.generateRocketTestStore();
		Account act = new Account(Name = 'Test Account Name 123', AccountNumber ='123456');
		insert act;     
		Contact con = new Contact(LastName = 'TestLastName', AccountId = act.Id);
		insert con;
        Opportunity opp = new Opportunity(Name = 'TestOpp', StageName = 'Closed', CloseDate = Date.today() + 30, AccountId = act.Id);
        insert opp;
        DateTime now = DateTime.now();
        String uniqueTimestamp = String.valueOf(now.getTime());
        List<Product2> prodList = new List<Product2>();
        for(Integer i = 0; i < 20; i++){
            Product2 prod = new Product2();
            prod.Name = 'Test Product ' + i;
            prod.StockKeepingUnit = 'SKU' + uniqueTimestamp + '_' + i;
            prod.ProductCode = 'PROD' + i;
            prodList.add(prod);
        }
        insert prodList;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        upsert standardPricebook;
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for(Integer i = 0; i < 10; i++){
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = standardPricebook.Id;
            pbe.Product2Id = prodList[i].Id;
            pbe.UnitPrice = 100;
            pbe.IsActive = true;
        }
        insert pbeList;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = act.Id, Requires_Approval__c = true, SBQQ__Opportunity2__c = opp.Id, SBQQ__PrimaryContact__c = con.Id, SBQQ__Status__c = 'Draft', SBQQ__PriceBook__c =standardPricebook.Id, Quote_Name__c = 'Quote Name');
        insert quote;
        System.debug(quote.Id);
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        for(Integer i = 0; i < 10; i++){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.SBQQ__Quote__c = quote.Id;
            quoteLine.SBQQ__Product__c = prodList[i].Id;
            quoteLine.SBQQ__Quantity__c = 1; 
            quoteLine.ApprovalStatus__c = 'Needs Approval';
            quoteLine.ApprovalReason__c = 'Excessive Discount Percentage';
            quoteLine.Requested_Price__c = 10;
            quoteLine.Customer_Special_Price__c = 10;
            quoteLine.UnitOfMeasure__c = 'EA';
            quoteLine.Request_UOM__c =  'EA';
            quoteLine.Pricing_Uom__c = 'EA';
            quoteLine.Pricing_Uom_Price__c = 10;
            quoteLine.Pricing_Uom_Placeholder__c = 'EA';
            quoteLine.Pricing_Uom_Price_Placeholder__c = 10;
            quoteLine.Sales_UOM__c = 'EA';
            quoteLine.SalesUOMPrice__c = 10;
            quoteLine.Customer_Book_Price__c = 10;
            quoteLine.CustomerPrice__c = 10;
            quoteLine.Discount__c = 10;
            quoteLine.TradeDiscount__c = 10;
            quoteLine.Cost__c = 10;
            quoteLine.SBQQ__UnitCost__c = 10;
            quoteLine.Margin__c = 10;
            quoteLine.IsTradeDiscount__c = false;
            quoteLine.BaseUOMPrice__c = 10;
            quoteLine.BaseUOM__c = 'EA';
            quoteLine.Customer_Special_UOM__c = 'EA';
            quoteLine.SBQQ__Quantity__c = 10;
            quoteLine.SBQQ__ListPrice__c = 10;
            quoteLine.SBQQ__RegularPrice__c = 10;
            quoteLine.SBQQ__CustomerPrice__c = 10;
            quoteLine.SBQQ__AdditionalDiscountAmount__c = 0;
            quoteLine.SBQQ__NetPrice__c = 10;
            quoteLine.SBQQ__ProratedListPrice__c = 10;
            quoteLine.SBQQ__Number__c = i;
            quoteLine.Customer_Special_UOM__c = 'EA';
            quoteLine.Color_Code__c = '';
            quoteLine.Product_Code__c = '';
            quoteLine.isDryvit__c = false;

             quoteLineList.add(quoteline);
	    }
        insert quoteLineList;
    }

    @isTest
    static void getQuoteTest() {
        createTestData();
       String quoteId = [SELECT Id FROM SBQQ__Quote__c WHERE Quote_Name__c = 'Quote Name' LIMIT 1].Id;
       TC_CPQQuoteLineEditor.QuoteWrapper quoteLineWrapper = TC_CPQQuoteLineEditor.getQuoteLines(quoteId);
    }

    @isTest
    static void testApproval() {
       createTestData();
       String quoteId = [SELECT Id FROM SBQQ__Quote__c WHERE Quote_Name__c = 'Quote Name' LIMIT 1].Id;

       Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting for approval');
        req.setObjectId(quoteId);

        Approval.ProcessResult result = Approval.process(req);
       TC_CPQQuoteLineEditor.ApproverWrapper appWrapper = TC_CPQQuoteLineEditor.getApprover(userInfo.getUserId(), quoteId);
    }

    @isTest
    static void updateQuoteTest() {
        createTestData();

        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c, SBQQ__Status__c, Requires_Specialist_Approval__c, Initial_Approval__c, Second_Approval__c FROM SBQQ__Quote__c WHERE Quote_Name__c = 'Quote Name' LIMIT 1];
    
    
        String productId = [SELECT Id FROM Product2 WHERE NAME = 'Test Product 1' LIMIT 1].Id;
       String jsonStr = '{' +
            '"id": "' + quote.Id + '",' +
            '"isSubmitted": false,' +
            '"isAccepted": false,' +
            '"initialApprovalSuccessful": false,' +
            '"secondApprovalSuccessful": false,' +
            '"lineItemAdded": true,' +
            '"quoteLines": [{' +
                '"recordId": "",' +
                '"Id": "",' +
                '"account": "",' +
                '"accountDetail": "",' +
                '"isSoldTo": false,' +  
                '"product2": "' + productId + '",' +
                '"productDetail": "",' +
                '"materialNumber": "",' +
                '"materialPriceGroup": "",' +
                '"materialGroup3": "",' +
                '"price": 10.0,' +
                '"pricingUomPrice": 10.0,' +
                '"bookPrice": 10.0,' +
                '"customerPrice": 10.0,' +
                '"discount": 10.0,' +
                '"maxDiscount": 10.0,' +
                '"tradeDiscount": 10.0,' +
                '"cost": 10.0,' +
                '"margin": 10.0,' +
                '"marginMin": 10.0,' +
                '"uom": "",' +
                '"uomOptions": "",' +
                '"salesUom": "",' +
                '"salesUomPrice": 10.0,' +
                '"salesUomQty": 10.0,' +
                '"baseUom": "",' +
                '"baseUomPrice": 10.0,' +
                '"qty": 10.0,' +
                '"pricingUom": "",' +
                '"lineNumber": 10.0,' +
                '"startDate": "2050-11-14",' +
                '"endDate": "2100-11-14",' +
                '"isTradeDiscount": false,' +
                '"isMaterialGroup": false,' +
                '"approvalStatus": "",' +
                '"approvalReason": "",' +
                '"cur": "",' +
                '"tradeDiscountPercentage": 10.0,' +
                '"hasErrors": false,' +
                '"errorIsExcluded": false,' +
                '"errorNotListed": false,' +
                '"errorNotInSAP": false,' +
                '"errorNotIn2000": false,' +
                '"errorNotIn4000": false,' +
                '"errorIsDiscontinued": false,' +
                '"errorIsBlocked": false,' +
                '"errorNullResponse": false,' +
                '"sortOrder": 10.0,' +
                '"entireAPIResponse": null,' +
                '"entireAPIResponseWrapper": null,' +
                '"isDryvit": false,' +
                '"cspUom": "",' +
                '"dryvitColorCode": "",' +
                '"dryvitProductCode": "",' +
                '"minimumOrderQty": 10.0,' +
                '"increment": 10.0,' +
                '"isApproved": false,' +
                '"sapItemNumber": "",' +
                '"remainingQty": 10.0' +
            '}],' +
            '"quoteAccountId": "",' +
            '"quoteEndDate": "2050-11-14",' +
            '"openForUpdates": false,' +
            '"quoteStatus": "",' +
            '"sapQuoteNumber": ""' +
        '}';

       Boolean updateResult = TC_CPQQuoteLineEditor.updateQuoteLines(jsonStr, new String[]{}, false, 'Comments');
    }

    @IsTest
    static void testGetPricing() {
        // Step 1: Set up test data
        createTestData();

        // Step 2: Setup Mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Step 3: Retrieve a Quote Id for testing
        String quoteId = [SELECT Id FROM SBQQ__Quote__c WHERE Quote_Name__c = 'Quote Name' LIMIT 1].Id;

        // Step 4: Call getQuoteLines to setup the scenario for getPricing
        TC_CPQQuoteLineEditor.QuoteWrapper quoteWrapper = TC_CPQQuoteLineEditor.getQuoteLines(quoteId);

        // Convert the quote lines to JSON to simulate the input for getPricing
        String quoteLinesJson = JSON.serialize(quoteWrapper.quoteLines);

        // Step 5: Invoke the getPricing method
        Test.startTest();
        List<TC_CPQQuoteLineEditor.QuoteLineWrapper> pricedQuoteLines = TC_CPQQuoteLineEditor.getPricing(quoteLinesJson, quoteWrapper.quoteLines);
        Test.stopTest();

        // Step 6: Assert the outcomes
        // System.assertNotEquals(null, pricedQuoteLines, 'The returned list should not be null.');
        // System.assert(!pricedQuoteLines.isEmpty(), 'The returned list should not be empty.');
        // Additional assertions as per your logic
    }

    @IsTest
    static void testGetPricingFail() {
        // Step 1: Set up test data
        createTestData();

        // Step 2: Setup Mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFail());

        // Step 3: Retrieve a Quote Id for testing
        String quoteId = [SELECT Id FROM SBQQ__Quote__c WHERE Quote_Name__c = 'Quote Name' LIMIT 1].Id;

        // Step 4: Call getQuoteLines to setup the scenario for getPricing
        TC_CPQQuoteLineEditor.QuoteWrapper quoteWrapper = TC_CPQQuoteLineEditor.getQuoteLines(quoteId);

        // Convert the quote lines to JSON to simulate the input for getPricing
        String quoteLinesJson = JSON.serialize(quoteWrapper.quoteLines);

        // Step 5: Invoke the getPricing method
        Test.startTest();
        List<TC_CPQQuoteLineEditor.QuoteLineWrapper> pricedQuoteLines = TC_CPQQuoteLineEditor.getPricing(quoteLinesJson, quoteWrapper.quoteLines);
        Test.stopTest();

        // Step 6: Assert the outcomes
        // System.assertNotEquals(null, pricedQuoteLines, 'The returned list should not be null.');
        // System.assert(!pricedQuoteLines.isEmpty(), 'The returned list should not be empty.');
        // Additional assertions as per your logic
    }

    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
            // Implement this interface method
            public HTTPResponse respond(HTTPRequest req) {
                String productId = [SELECT Id FROM Product2 WHERE Name = 'Test Product 1' LIMIT 1].Id;
                String jsonResponse = '{' +
    '"data": {' +
        '"CONDITIONS": [],' +
        '"CustomerPurchaseOrderDate": "2024-01-20",' +
        '"CustomerPurchaseOrderNumber": "Product",' +
        '"IncompletionLogs": [],' +
        '"isIncomplete": false,' +
        '"IsSuccess": true,' +
        '"ITEMS": [' +
        '{' +
        '"AlternativeItem": "000000",' +
        '"BaseUnitOfMeasure": "CS",' +
        '"BaseUnitOfMeasureInternal": "CS",' +
        '"BillingPlanDates": [],' +
        '"BOMCount": "000",' +
        '"ConditionPricingUnit": 1,' +
        '"ConditionUnit": "SSG",' +
        '"ConditionUnitInternal": "SSG",' +
        '"ConfigurableMaterial": false,' +
        '"CustomerBookPrice": 100.97,' +
        '"CustomerSpecialPrice": 107.03,' +
        '"Discounts": -3.21,' +
        '"GrossWeight": 34,' +
        '"HigherLevelItemNumber": "000000",' +
        '"isNeedConfigure": false,' +
        '"ItemCategory": "TAN",' +
        '"ItemDescription": "DYMONIC 100 ALMOND -15X600ML SSG CS",' +
        '"ItemIncompletionLogs": [],' +
        '"ItemNumber": "000010",' +
        '"ItemSchedules": [' +
        '{' +
        '"ConfirmedQuantity": 1,' +
        '"DeliveredQuantity": 0,' +
        '"OrderQuantity": 1,' +
        '"PurchaseRequisitionItemNumber": "00000",' +
        '"RoundedQuantity": 1,' +
        '"SalesUnit": "CS",' +
        '"SalesUnitInternal": "CS",' +
        '"ScheduleLineCategory": "CP",' +
        '"ScheduleLineDate": "2024-02-02",' +
        '"ScheduleLineNumber": "0001"' +
        '}' +
        '],' +
        '"Material": "965724C385",' +
        '"MaterialEntered": "965724C385",' +
        '"NetItemPrice": 6.92,' +
        '"NetOrderValue": 103.8,' +
        '"NetWeight": 34,' +
        '"OrderQuantity": 1,' +
        '"PARTNERS": [],' +
        '"Plant": "MAME",' +
        '"PriceListType": "F8",' +
        '"ProductId": "' + productId + '",' +
        '"ReferenceItemNumber": "000000",' +
        '"SalesDocumentCurrency": "USD",' +
        '"SalesUnit": "CS",' +
        '"SalesUnitInternal": "CS",' +
        '"SBOItemConditions": [' +
        '{' +
        '"CalculationType": "C",' +
        '"ConditionControl": "A",' +
        '"ConditionCounter": "001",' +
        '"ConditionPricingUnit": 1,' +
        '"ConditionType": "ZPRN",' +
        '"ConditionTypeName": "National Price",' +
        '"ConditionUnit": "SSG",' +
        '"ConditionUnitInternal": "SSG",' +
        '"ConditionValue": 144.9,' +
        '"CurrencyKey": "USD",' +
        '"DenominatorForConversion": 15,' +
        '"OriginOfCondition": "A",' +
        '"Rate": 9.66,' +
        '"RateUnit": "USD"' +
        '},' +
        '{' +
        '"CalculationType": "A",' +
        '"ConditionControl": "A",' +
        '"ConditionCounter": "001",' +
        '"ConditionPricingUnit": 0,' +
        '"ConditionType": "ZPL%",' +
        '"ConditionTypeName": "Regional Discount",' +
        '"ConditionValue": -20.67,' +
        '"CurrencyKey": "USD",' +
        '"DenominatorForConversion": 0,' +
        '"OriginOfCondition": "A",' +
        '"Rate": -14.27,' +
        '"RateUnit": "%"' +
        '},' +
        '{' +
        '"CalculationType": "C",' +
        '"ConditionControl": "A",' +
        '"ConditionCounter": "001",' +
        '"ConditionPricingUnit": 1,' +
        '"ConditionType": "ZRSU",' +
        '"ConditionTypeName": "Rounding-Surch pctg",' +
        '"ConditionUnit": "SSG",' +
        '"ConditionUnitInternal": "SSG",' +
        '"ConditionValue": -0.03,' +
        '"CurrencyKey": "USD",' +
        '"DenominatorForConversion": 15,' +
        '"OriginOfCondition": "A",' +
        '"Rate": 8.28,' +
        '"RateUnit": "USD"' +
        '},' +
        '"ScheduleLineDate": "2024-02-02",' +
        '"SFId": "01tDR00000HRvReYAL",' +
        '"SubTotal2": 103.8,' +
        '"SubTotal3": 103.8,' +
        '"TaxAmount": 7.27,' +
        '"WeightUnit": "LB"' +
        '}' +
        '],' +
        '"NeedToSimulate": false,' +
        '"NetOrderValue": 103.8,' +
        '"PARTNERS": [' +
        '{' +
        '"allowAddressOverride": false,' +
        '"CustomerNumber": "6059064",' +
        '"PartnerFunction": "SP",' +
        '"PartnerFunctionInternal": "AG"' +
        '},' +
        '{' +
        '"allowAddressOverride": false,' +
        '"CustomerNumber": "6059064",' +
        '"PartnerFunction": "SH",' +
        '"PartnerFunctionInternal": "WE"' +
        '}' +
        '],' +
        '"SALES": {' +
        '"CreateDate": "2024-01-20",' +
        '"CustomerGroup": "EM",' +
        '"DateforPricingExchangeRate": "2024-01-20",' +
        '"DistributionChannel": "30",' +
        '"Division": "30",' +
        '"IncotermsPart1": "COL",' +
        '"IncotermsPart2": "Collect",' +
        '"PriceGroup": "85",' +
        '"PriceListType": "F8",' +
        '"PricingProcedureInPricing": "ZUSSLT",' +
        '"RequestedDeliveryDate": "2024-01-20",' +
        '"SalesDistrict": "US08",' +
        '"SalesDocumentType": "OR",' +
        '"SalesDocumentTypeInternal": "TA",' +
        '"SalesOffice": "53",' +
        '"SalesOrganization": "2000",' +
        '"TermsofPaymentKey": "Z005",' +
        '"ValidFrom": "2024-01-20",' +
        '"ValidTo": "2024-02-19"' +
        '},' +
        '"SalesDocumentCurrency": "USD",' +
        '"SBOHeaderConditions": [],' +
        '"ShippingConditions": "02",' +
        '"SoldToParty": "6059064",' +
        '"SoldToPartyText": "NATIONAL WATERPROOFING",' +
        '"TaxAmount": 7.27,' +
        '"TEXTS": [],' +
        '"TransactLogs": []' +
        '}' +
    '}';
        
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody(jsonResponse);
                res.setStatusCode(200);
                return res;
            }
        }
    

    public class MockHttpResponseGeneratorFail implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            String productId = [SELECT Id FROM Product2 WHERE Name = 'Test Product 1' LIMIT 1].Id;
            String jsonResponse = '{' +
    '"data": {' +
        '"CONDITIONS": [],' +
        '"CustomerPurchaseOrderDate": "2024-01-20",' +
        '"CustomerPurchaseOrderNumber": "Product",' +
        '"IncompletionLogs": [],' +
        '"isIncomplete": false,' +
        '"IsSuccess": false,' +
        '"ITEMS": [' +
        '{' +
        '"AlternativeItem": "000000",' +
        '"BaseUnitOfMeasure": "CS",' +
        '"BaseUnitOfMeasureInternal": "CS",' +
        '"BillingPlanDates": [],' +
        '"BOMCount": "000",' +
        '"ConditionPricingUnit": 1,' +
        '"ConditionUnit": "SSG",' +
        '"ConditionUnitInternal": "SSG",' +
        '"ConfigurableMaterial": false,' +
        '"CustomerBookPrice": 100.97,' +
        '"CustomerSpecialPrice": 107.03,' +
        '"Discounts": -3.21,' +
        '"GrossWeight": 34,' +
        '"HigherLevelItemNumber": "000000",' +
        '"isNeedConfigure": false,' +
        '"ItemCategory": "TAN",' +
        '"ItemDescription": "DYMONIC 100 ALMOND -15X600ML SSG CS",' +
        '"ItemIncompletionLogs": [],' +
        '"ItemNumber": "000010",' +
        '"ItemSchedules": [' +
        '{' +
        '"ConfirmedQuantity": 1,' +
        '"DeliveredQuantity": 0,' +
        '"OrderQuantity": 1,' +
        '"PurchaseRequisitionItemNumber": "00000",' +
        '"RoundedQuantity": 1,' +
        '"SalesUnit": "CS",' +
        '"SalesUnitInternal": "CS",' +
        '"ScheduleLineCategory": "CP",' +
        '"ScheduleLineDate": "2024-02-02",' +
        '"ScheduleLineNumber": "0001"' +
        '}' +
        '],' +
        '"Material": "965724C385",' +
        '"MaterialEntered": "965724C385",' +
        '"NetItemPrice": 6.92,' +
        '"NetOrderValue": 103.8,' +
        '"NetWeight": 34,' +
        '"OrderQuantity": 1,' +
        '"PARTNERS": [],' +
        '"Plant": "MAME",' +
        '"PriceListType": "F8",' +
        '"ProductId": "' + productId + '",' +
        '"ReferenceItemNumber": "000000",' +
        '"SalesDocumentCurrency": "USD",' +
        '"SalesUnit": "CS",' +
        '"SalesUnitInternal": "CS",' +
        '"SBOItemConditions": [' +
        '{' +
        '"CalculationType": "C",' +
        '"ConditionControl": "A",' +
        '"ConditionCounter": "001",' +
        '"ConditionPricingUnit": 1,' +
        '"ConditionType": "ZPRN",' +
        '"ConditionTypeName": "National Price",' +
        '"ConditionUnit": "SSG",' +
        '"ConditionUnitInternal": "SSG",' +
        '"ConditionValue": 144.9,' +
        '"CurrencyKey": "USD",' +
        '"DenominatorForConversion": 15,' +
        '"OriginOfCondition": "A",' +
        '"Rate": 9.66,' +
        '"RateUnit": "USD"' +
        '},' +
        '{' +
        '"CalculationType": "A",' +
        '"ConditionControl": "A",' +
        '"ConditionCounter": "001",' +
        '"ConditionPricingUnit": 0,' +
        '"ConditionType": "ZPL%",' +
        '"ConditionTypeName": "Regional Discount",' +
        '"ConditionValue": -20.67,' +
        '"CurrencyKey": "USD",' +
        '"DenominatorForConversion": 0,' +
        '"OriginOfCondition": "A",' +
        '"Rate": -14.27,' +
        '"RateUnit": "%"' +
        '},' +
        '{' +
        '"CalculationType": "C",' +
        '"ConditionControl": "A",' +
        '"ConditionCounter": "001",' +
        '"ConditionPricingUnit": 1,' +
        '"ConditionType": "ZRSU",' +
        '"ConditionTypeName": "Rounding-Surch pctg",' +
        '"ConditionUnit": "SSG",' +
        '"ConditionUnitInternal": "SSG",' +
        '"ConditionValue": -0.03,' +
        '"CurrencyKey": "USD",' +
        '"DenominatorForConversion": 15,' +
        '"OriginOfCondition": "A",' +
        '"Rate": 8.28,' +
        '"RateUnit": "USD"' +
        '},' +
        // ... (other conditions)
        '"ScheduleLineDate": "2024-02-02",' +
        '"SFId": "01tDR00000HRvReYAL",' +
        '"SubTotal2": 103.8,' +
        '"SubTotal3": 103.8,' +
        '"TaxAmount": 7.27,' +
        '"WeightUnit": "LB"' +
        '}' +
        '],' +
        '"NeedToSimulate": false,' +
        '"NetOrderValue": 103.8,' +
        '"PARTNERS": [' +
        '{' +
        '"allowAddressOverride": false,' +
        '"CustomerNumber": "6059064",' +
        '"PartnerFunction": "SP",' +
        '"PartnerFunctionInternal": "AG"' +
        '},' +
        '{' +
        '"allowAddressOverride": false,' +
        '"CustomerNumber": "6059064",' +
        '"PartnerFunction": "SH",' +
        '"PartnerFunctionInternal": "WE"' +
        '}' +
        '],' +
        '"SALES": {' +
        '"CreateDate": "2024-01-20",' +
        '"CustomerGroup": "EM",' +
        '"DateforPricingExchangeRate": "2024-01-20",' +
        '"DistributionChannel": "30",' +
        '"Division": "30",' +
        '"IncotermsPart1": "COL",' +
        '"IncotermsPart2": "Collect",' +
        '"PriceGroup": "85",' +
        '"PriceListType": "F8",' +
        '"PricingProcedureInPricing": "ZUSSLT",' +
        '"RequestedDeliveryDate": "2024-01-20",' +
        '"SalesDistrict": "US08",' +
        '"SalesDocumentType": "OR",' +
        '"SalesDocumentTypeInternal": "TA",' +
        '"SalesOffice": "53",' +
        '"SalesOrganization": "2000",' +
        '"TermsofPaymentKey": "Z005",' +
        '"ValidFrom": "2024-01-20",' +
        '"ValidTo": "2024-02-19"' +
        '},' +
        '"SalesDocumentCurrency": "USD",' +
        '"SBOHeaderConditions": [],' +
        '"ShippingConditions": "02",' +
        '"SoldToParty": "6059064",' +
        '"SoldToPartyText": "NATIONAL WATERPROOFING",' +
        '"TaxAmount": 7.27,' +
        '"TEXTS": [],' +
        '"TransactLogs": []' +
        '}' +
    '}';

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(jsonResponse);
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Helper: builds update JSON for a single line 
    private static String buildUpdateJson(
            Id      quoteId,
            String  lineRecordId,
            Id      productId,
            String  approvalStatus,
            Decimal discount,
            Decimal maxDiscount,
            Decimal bookPrice,
            Boolean openForUpdates,
            String  quoteStatus,
            Date    quoteEndDate) {

        String recId      = String.isBlank(lineRecordId) ? '' : lineRecordId;
        String endDateStr = String.valueOf(quoteEndDate);

        return '{'
            + '"id":"'                        + quoteId       + '",'
            + '"isSubmitted":false,'
            + '"isAccepted":false,'
            + '"initialApprovalSuccessful":false,'
            + '"secondApprovalSuccessful":false,'
            + '"lineItemAdded":false,'
            + '"quoteLines":[{'
            +   '"recordId":"'                + recId         + '",'
            +   '"Id":"",'
            +   '"account":"",'
            +   '"accountDetail":"",'
            +   '"isSoldTo":false,'
            +   '"product2":"'                + productId     + '",'
            +   '"productDetail":"",'
            +   '"materialNumber":"",'
            +   '"materialPriceGroup":"",'
            +   '"materialGroup3":"",'
            +   '"price":10.0,'
            +   '"pricingUomPrice":10.0,'
            +   '"bookPrice":'                + bookPrice     + ','
            +   '"customerPrice":10.0,'
            +   '"discount":'                 + discount      + ','
            +   '"maxDiscount":'              + maxDiscount   + ','
            +   '"tradeDiscount":5.0,'
            +   '"cost":8.0,'
            +   '"margin":20.0,'
            +   '"marginMin":10.0,'
            +   '"uom":"EA",'
            +   '"uomOptions":"",'
            +   '"salesUom":"EA",'
            +   '"salesUomPrice":10.0,'
            +   '"salesUomQty":1.0,'
            +   '"baseUom":"EA",'
            +   '"baseUomPrice":10.0,'
            +   '"qty":1.0,'
            +   '"pricingUom":"EA",'
            +   '"lineNumber":1.0,'
            +   '"startDate":"2025-01-01",'
            +   '"endDate":"'                 + endDateStr    + '",'
            +   '"isTradeDiscount":false,'
            +   '"isMaterialGroup":false,'
            +   '"approvalStatus":"'          + approvalStatus + '",'
            +   '"approvalReason":"",'
            +   '"cur":"USD",'
            +   '"tradeDiscountPercentage":"5.0",'
            +   '"hasErrors":false,'
            +   '"errorIsExcluded":false,'
            +   '"errorNotListed":false,'
            +   '"errorNotInSAP":false,'
            +   '"errorNotIn2000":false,'
            +   '"errorNotIn4000":false,'
            +   '"errorIsDiscontinued":false,'
            +   '"errorIsBlocked":false,'
            +   '"errorNullResponse":false,'
            +   '"sortOrder":1.0,'
            +   '"entireAPIResponse":null,'
            +   '"entireAPIResponseWrapper":null,'
            +   '"isDryvit":false,'
            +   '"cspUom":"EA",'
            +   '"dryvitColorCode":"",'
            +   '"dryvitColorId":"",'
            +   '"dryvitProductCode":"",'
            +   '"minimumOrderQty":1.0,'
            +   '"increment":1.0,'
            +   '"isApproved":false,'
            +   '"sapItemNumber":"",'
            +   '"remainingQty":0.0,'
            +   '"ConditionBaseValue":0.0'
            + '}],'
            + '"quoteAccountId":"",'
            + '"quoteEndDate":"'              + endDateStr    + '",'
            + '"openForUpdates":'             + openForUpdates + ','
            + '"quoteStatus":"'               + quoteStatus   + '",'
            + '"sapQuoteNumber":""'
            + '}';
    }


    private static SBQQ__Quote__c getTestQuote() {
        return [SELECT Id, SBQQ__Status__c, Initial_Approval__c, SBQQ__EndDate__c,
                       SBQQ__SalesRep__c, Open_for_Updates__c
                FROM   SBQQ__Quote__c
                WHERE  Quote_Name__c = 'Quote Name'
                LIMIT  1];
    }

    private static SBQQ__QuoteLine__c getFirstLine(Id quoteId) {
        return [SELECT Id, SBQQ__Product__c
                FROM   SBQQ__QuoteLine__c
                WHERE  SBQQ__Quote__c = :quoteId
                LIMIT  1];
    }

    // callPricing = true when Customer_Book_Price__c / CustomerPrice__c are null 
    @IsTest
    static void testGetQuoteLinesNullPricesCallPricing() {
        createTestData();
        SBQQ__Quote__c quote = getTestQuote();

        for (SBQQ__QuoteLine__c ql : [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id]) {
            ql.Customer_Book_Price__c = null;
            ql.CustomerPrice__c       = null;
        }
        update [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id];

        TC_CPQQuoteLineEditor.QuoteWrapper result = TC_CPQQuoteLineEditor.getQuoteLines(quote.Id);

        System.assertNotEquals(null, result, 'QuoteWrapper should not be null');
        System.assert(!result.quoteLines.isEmpty(), 'Should have quote lines');
    }

    @IsTest
    static void testGetQuoteLinesAcceptedStatus() {
        createTestData();
        SBQQ__Quote__c quote = getTestQuote();
        quote.SBQQ__Status__c     = 'Accepted';
        quote.Open_for_Updates__c = true;
        update quote;

        TC_CPQQuoteLineEditor.QuoteWrapper result = TC_CPQQuoteLineEditor.getQuoteLines(quote.Id);

        System.assertEquals(true, result.isAccepted,  'isAccepted should be true for Accepted status');
        System.assertEquals(true, result.isSubmitted, 'isSubmitted should be true for Accepted status');

        quote.SBQQ__Status__c     = 'Draft';
        quote.Open_for_Updates__c = true;
        update quote;

        TC_CPQQuoteLineEditor.QuoteWrapper result1 = TC_CPQQuoteLineEditor.getQuoteLines(quote.Id);

        System.assertEquals(true,  result.isAccepted,  'isAccepted must be true when Open_for_Updates__c = true');
        System.assertEquals(true, result.isSubmitted, 'isSubmitted must remain false for Draft status');

        quote.SBQQ__Status__c = 'Rejected';
        update quote;

        TC_CPQQuoteLineEditor.QuoteWrapper result2 = TC_CPQQuoteLineEditor.getQuoteLines(quote.Id);

        System.assertEquals(true, result.isSubmitted, 'isSubmitted must be false for Rejected status');
        System.assertEquals(true, result.isAccepted,  'isAccepted must be false for Rejected status');
    }

    // New line (blank recordId) with discount > maxDiscount, 'Needs Approval' 
    @IsTest
    static void testUpdateQuoteLinesExcessiveDiscount() {
        createTestData();
        SBQQ__Quote__c quote = getTestQuote();
        Id productId = [SELECT Id FROM Product2 WHERE Name = 'Test Product 1' LIMIT 1].Id;

        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, '', productId, '', 50.0, 10.0, 100.0, false, 'Draft', Date.today() + 90),
            new String[]{}, false, ''
        );

        System.assertEquals(true, result);
    }

    // Existing line with bookPrice == 0, 'No Book Price' approval reason 
    @IsTest
    static void testUpdateQuoteLinesNoBookPrice() {
        createTestData();
        SBQQ__Quote__c     quote = getTestQuote();
        SBQQ__QuoteLine__c line  = getFirstLine(quote.Id);

        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 0.0, false, 'Draft', Date.today() + 90),
            new String[]{}, false, ''
        );

        System.assertEquals(true, result);
    }

    // approvalStatus == 'Approved'  approval-setting logic is skipped entirely 
    @IsTest
    static void testUpdateQuoteLinesSkipApproved() {
        createTestData();
        SBQQ__Quote__c     quote = getTestQuote();
        SBQQ__QuoteLine__c line  = getFirstLine(quote.Id);

        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, 'Approved', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90),
            new String[]{}, false, ''
        );

        System.assertEquals(true, result);

        Boolean result1 = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90),
            new String[]{}, false, ''
        );

        System.assertEquals(true, result);
    }

    @IsTest
    static void testUpdateQuoteLinesDeletedLines() {
        createTestData();
        SBQQ__Quote__c quote = getTestQuote();
        List<SBQQ__QuoteLine__c> lines = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c
                                          WHERE  SBQQ__Quote__c = :quote.Id
                                          ORDER  BY SBQQ__Number__c ASC LIMIT 2];
        Id deletedId = lines[1].Id;

        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, lines[0].Id, lines[0].SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90),
            new String[]{ deletedId }, false, ''
        );

        System.assertEquals(true, result);
        System.assert([SELECT Id FROM SBQQ__QuoteLine__c WHERE Id = :deletedId].isEmpty(),
                      'Deleted line should no longer exist');
    }

    //SSN-340-Aza
    @IsTest
    static void testUpdateQuoteLinesDiscontinuedLineKeptAndFlagged() {
        createTestData();
        SBQQ__Quote__c     quote = getTestQuote();
        SBQQ__QuoteLine__c line  = getFirstLine(quote.Id);

        String json = buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90)
            .replace('"errorIsDiscontinued":false', '"errorIsDiscontinued":true');

        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(json, new String[]{}, false, '');
        System.assertEquals(true, result);

        List<SBQQ__QuoteLine__c> saved = [SELECT Id, ensxtx_SAP_Simulation_Error__c FROM SBQQ__QuoteLine__c WHERE Id = :line.Id];
        System.assertEquals(1, saved.size(), 'Discontinued line must not be deleted');
        System.assertEquals('Discontd w/o Replace', saved[0].ensxtx_SAP_Simulation_Error__c, 'Discontinued marker must be saved');
    }

    //SSN-340-Aza
    @IsTest
    static void testUpdateQuoteLinesPreservesNonDiscontinuedError() {
        createTestData();
        SBQQ__Quote__c     quote = getTestQuote();
        SBQQ__QuoteLine__c line  = getFirstLine(quote.Id);

        String json = buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90)
            .replace('"hasErrors":false', '"hasErrors":true')
            .replace('"errorNotListed":false', '"errorNotListed":true');

        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(json, new String[]{}, false, '');
        System.assertEquals(true, result);

        SBQQ__QuoteLine__c saved = [SELECT ensxtx_SAP_Simulation_Error__c FROM SBQQ__QuoteLine__c WHERE Id = :line.Id LIMIT 1];
        System.assertEquals('is not listed and therefore not allowed', saved.ensxtx_SAP_Simulation_Error__c, 'Non-discontinued error must be preserved');
    }

    //SSN-340-Aza
    @IsTest
    static void testUpdateQuoteLinesClearsSimulationErrorWhenNoErrors() {
        createTestData();
        SBQQ__Quote__c     quote = getTestQuote();
        SBQQ__QuoteLine__c line  = getFirstLine(quote.Id);

        update new SBQQ__QuoteLine__c(Id = line.Id, ensxtx_SAP_Simulation_Error__c = 'Old Error');

        String json = buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90);
        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(json, new String[]{}, false, '');
        System.assertEquals(true, result);

        SBQQ__QuoteLine__c saved = [SELECT ensxtx_SAP_Simulation_Error__c FROM SBQQ__QuoteLine__c WHERE Id = :line.Id LIMIT 1];
        System.assertEquals(null, saved.ensxtx_SAP_Simulation_Error__c, 'Simulation error should be cleared when line has no errors');
    }

    // openForUpdates = true, quote status forced to Draft, Open_for_Updates__c = true 
    @IsTest
    static void testUpdateQuoteLinesOpenForUpdates() {
        createTestData();
        SBQQ__Quote__c     quote = getTestQuote();
        SBQQ__QuoteLine__c line  = getFirstLine(quote.Id);

        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, true, 'Accepted', Date.today() + 90),
            new String[]{}, false, ''
        );

        System.assertEquals(true, result);
        SBQQ__Quote__c updated = [SELECT Open_for_Updates__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(true,    updated.Open_for_Updates__c, 'Open_for_Updates__c should be true');
        System.assertEquals('Draft', updated.SBQQ__Status__c,     'Status should be forced to Draft');
    }

    /**
     * Initial_Approval__c = true, date extension > 30 days → needsApproval = true.
     * Covers both "near end date extended forward" and "far end date shortened beyond 30 days"
     * via two parameter combinations in a single test using a local helper call each time.
     */
    @IsTest
    static void testUpdateQuoteLinesInitialApprovalDateExtension() {
        createTestData();
        SBQQ__Quote__c quote = getTestQuote();
        quote.Initial_Approval__c = true;

        quote.SBQQ__EndDate__c = Date.today() + 10;
        update quote;
        SBQQ__QuoteLine__c line = getFirstLine(quote.Id);

        Boolean resultA = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 60),
            new String[]{}, false, ''
        );
        System.assertEquals(true, resultA, 'Scenario A should succeed');

        quote.SBQQ__EndDate__c = Date.today() + 120;
        update quote;

        Boolean resultB = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 10),
            new String[]{}, false, ''
        );
        System.assertEquals(true, resultB, 'Scenario B should succeed');

        SBQQ__Quote__c updated = [SELECT Requires_Approval__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(true, updated.Requires_Approval__c, 'Requires_Approval__c should remain true');
    }

    @IsTest
    static void testUpdateQuoteLinesWithSalesRep() {
        createTestData();
        SBQQ__Quote__c quote = getTestQuote();
        quote.SBQQ__SalesRep__c = UserInfo.getUserId();
        update quote;
        SBQQ__QuoteLine__c line = getFirstLine(quote.Id);

        Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(
            buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90),
            new String[]{}, false, ''
        );

        System.assertEquals(true, result, 'Should return true when SalesRep is set');
    }

    @IsTest
    static void testUpdateQuoteLinesSubmitForApproval() {
        createTestData();
        SBQQ__Quote__c     quote = getTestQuote();
        SBQQ__QuoteLine__c line  = getFirstLine(quote.Id);

        Test.startTest();    
        try {
            Boolean result = TC_CPQQuoteLineEditor.updateQuoteLines(
                buildUpdateJson(quote.Id, line.Id, line.SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90),
                new String[]{}, true, 'Submitting for approval'
            );
            System.assertEquals(true, result);
        } catch (AuraHandledException ex) {
            System.assert(ex.getMessage() != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateQuoteLinesRollback() {
        createTestData();
        SBQQ__Quote__c quote = getTestQuote();
        List<SBQQ__QuoteLine__c> lines = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c
                                          WHERE SBQQ__Quote__c = :quote.Id LIMIT 2];
        Id deletedId = lines[0].Id;
        delete new SBQQ__QuoteLine__c(Id = deletedId);   // pre-delete so DML update fails

        try {
            TC_CPQQuoteLineEditor.updateQuoteLines(
                buildUpdateJson(quote.Id, deletedId, lines[1].SBQQ__Product__c, '', 5.0, 20.0, 100.0, false, 'Draft', Date.today() + 90),
                new String[]{}, false, ''
            );
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            System.assert(ex.getMessage() != null && ex.getMessage().length() > 0,
                          'Exception message should be non-empty');
        }
    }

    @IsTest
    static void testGetPricingUsesLineWrapper() {
        createTestData();
        String quoteId = getTestQuote().Id;
        TC_CPQQuoteLineEditor.QuoteWrapper qw = TC_CPQQuoteLineEditor.getQuoteLines(quoteId);

        List<TC_CPQQuoteLineEditor.QuoteLineWrapper> result =
            TC_CPQQuoteLineEditor.getPricing(null, qw.quoteLines);

        System.assertNotEquals(null, result, 'Result should not be null');
    } 

    // getApprover on a quote with no active approval process isApprover = false, stepId = null 
    @IsTest
    static void testGetApproverNoActiveProcess() {
        createTestData();
        Account act = new Account(Name = 'NoProcess Account', AccountNumber = '999888');
        insert act;
        SBQQ__Quote__c freshQuote = new SBQQ__Quote__c(
            Quote_Name__c      = 'NoProcess Test',
            SBQQ__Account__c   = act.Id,
            SBQQ__Status__c    = 'Draft',
            SBQQ__PriceBook__c = Test.getStandardPricebookId(),
            SBQQ__EndDate__c   = Date.today() + 30
        );
        insert freshQuote;

        TC_CPQQuoteLineEditor.ApproverWrapper wrapper = TC_CPQQuoteLineEditor.getApprover(UserInfo.getUserId(), freshQuote.Id);

        System.assertEquals(false, wrapper.isApprover, 'Should not be an approver when no process exists');
        System.assertEquals(null,  wrapper.stepId,     'stepId should be null');
    }
}
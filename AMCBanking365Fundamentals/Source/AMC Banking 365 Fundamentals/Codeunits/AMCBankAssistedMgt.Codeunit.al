codeunit 20117 "AMC Bank Assisted Mgt."
{
    trigger OnRun()
    begin

    end;

    var
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        NotCorrectUserLbl: Label 'The Web Service Setup User Name (%1) does not match the License number (%2) or the (%3)', Comment = '%1=UserName, %2=License numnber, %3=DemoUser';
        YouHave2OptionsLbl: Label 'You have two option to change this:';
        UseBCLicenseLbl: Label '1. Please register the User Name (%1) using the Sign-up URL %2', Comment = '%1=User Name, %2=Sign-up URL';
        UseDemoUserLbl: Label '2. Delete the Web Service setup record using the Trash can symbol and reopen the page to use (%1)', Comment = '%1=DemoUser';
        TryLoadErrorLbl: Label 'The web service returned an error message:\';
        AssistedSetupNeededNotificationTxt: Label 'The AMC Banking 365 Fundamentals extension needs some information.';
        AssistedSetupNotificationActionTxt: Label 'Do you want to open the AMC Banking Setup page to run the Assisted Setup action?';

        DemoSolutionNotificationTxt: Label 'The AMC Banking 365 Fundamentals extension is in Demo mode.';
        DemoSolutionNotificationActionTxt: Label 'Do you want to open the AMC Banking 365 Fundamentals extension setup page?';
        DemoSolutionNotificationNameTok: Label 'Notify user of AMC Banking Demo solution.';
        DemoSolutionNotificationDescTok: Label 'Show a notification informing the user that AMC Banking is working in Demo solution.';
        DontShowThisAgainMsg: Label 'Don''t show this again.';

        AssistedSetupTxt: Label 'Set up AMC Banking 365 Fundamentals extension';

        AssistedSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2115384', Locked = true;
        AssistedSetupDescriptionTxt: Label 'Connect to an online bank service that can convert bank data from Business Central into the formats of your bank, to make it easier, and more accurate, to send data to your banks.';
        ReturnPathTxt: Label '//return/pack', Locked = true;
        ModuleWebCallTxt: Label 'amcwebservice', locked = true;
        DataExchangeWebCallTxt: Label 'dataExchange', Locked = true;
        ResponseNodeTxt: Label 'Response', Locked = true;

    procedure GetApplVersion() ApplVersion: Text;
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        ApplVersion := COPYSTR(ApplicationSystemConstants.ApplicationVersion(), STRPOS(ApplicationSystemConstants.ApplicationVersion(), ' ') + 1, STRLEN(ApplicationSystemConstants.ApplicationVersion()));
        ApplVersion := DELCHR(ApplVersion, '=', DELCHR(ApplVersion, '=', '.1234567890'));
        ApplVersion += '_F'; //To know the difference between Fundamentals and other versions

        OnGetApplVersion(ApplVersion); //Other Apps can call this Event to set their own ApplVersion
        exit(ApplVersion);
    end;

    procedure GetBuildNumber() BuildNumber: Text;
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        BuildNumber := ApplicationSystemConstants.ApplicationBuild();
        OnGetBuildNumber(BuildNumber); //Other Apps can call this Event to set their own BuildNumber

        exit(BuildNumber);
    end;

    [Obsolete('This method is obsolete. A new RunBasisSetup overload is available, with the an extra parameters (TempOnlineBankAccLink: Record "Online Bank Acc. Link") to control which bank account should be updated.', '16.0')]
    procedure RunBasisSetup(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                            UpdBank: Boolean; UpdPayMeth: Boolean; BankCountryCode: Code[10]; PaymCountryCode: Code[10];
                            UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean; UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                            UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; CallLicenseServer: Boolean): Boolean;
    var
        TempOnlineBankAccLink: Record "Online Bank Acc. Link" temporary;
    begin

        clear(TempOnlineBankAccLink);
        RunBasisSetupV162(UpdURL, URLSChanged, SignupURL, ServiceURL, SupportURL,
                      UpdBank, UpdPayMeth, BankCountryCode, PaymCountryCode,
                      UpdDataExchDef, UpdCreditTransfer, UpdPositivePay, UpdateStatementImport, UpdCreditAdvice, ApplVer, BuildNo,
                      UpdBankClearStd, UpdBankAccounts, TempOnlineBankAccLink, CallLicenseServer); //Call new version of RunBasisSetup
    end;

    [Obsolete('This method is obsolete. A new RunBasisSetupV162 is available, with the TempOnlineBankAccLink passed by var.', '16.2')]
    procedure RunBasisSetup(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                                    UpdBank: Boolean; UpdPayMeth: Boolean; BankCountryCode: Code[10]; PaymCountryCode: Code[10];
                                    UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean; UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                                    UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; TempOnlineBankAccLink: Record "Online Bank Acc. Link"; CallLicenseServer: Boolean): Boolean;
    begin
        RunBasisSetupV162(UpdURL, URLSChanged, SignupURL, ServiceURL, SupportURL,
                              UpdBank, UpdPayMeth, BankCountryCode, PaymCountryCode,
                              UpdDataExchDef, UpdCreditTransfer, UpdPositivePay, UpdateStatementImport, UpdCreditAdvice, ApplVer, BuildNo,
                              UpdBankClearStd, UpdBankAccounts, TempOnlineBankAccLink, CallLicenseServer); //Call new version of RunBasisSetup
    end;

    procedure RunBasisSetupV162(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                            UpdBank: Boolean; UpdPayMeth: Boolean; BankCountryCode: Code[10]; PaymCountryCode: Code[10];
                            UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean; UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                            UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; var TempOnlineBankAccLink: Record "Online Bank Acc. Link"; CallLicenseServer: Boolean): Boolean;
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        AMCBankServiceSetup: Record "AMC Banking Setup";
        AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
        LongTimeout: Integer;
        ShortTimeout: Integer;
        AMCBoughtModule: Boolean;
        AMCSolution: text;
        AMCSpecificURL: Text;
        AMCSignUpURL: Text;
        AMCSupportURL: Text;
        BasisSetupRanOK: Boolean;
        DataExchDef_Filter: Text;
        Error_Text: text;
    begin
        ShortTimeout := 5000;
        LongTimeout := 30000;
        BasisSetupRanOK := true;

        if (NOT AMCBankServiceSetup.Get()) then begin
            AMCBankServiceSetup.Init();
            AMCBankServiceSetup.Insert(true);
            Commit(); //Need to commit, to make sure record exist, if RunBasisSetup at one point is called from Installation/Upgrade CU
        end;

        if ((AMCBankServiceSetup."User Name" <> AMCBankServiceSetup.GetDemoUserName()) and
           (AMCBankServiceSetup."User Name" <> AMCBankServMgt.GetLicenseNumber())) then begin
            Error_Text := StrSubstNo(NotCorrectUserLbl, AMCBankServiceSetup."User Name", AMCBankServMgt.GetLicenseNumber(), AMCBankServiceSetup.GetDemoUserName()) + '\\' +
                          YouHave2OptionsLbl + '\\' +
                          StrSubstNo(UseBCLicenseLbl, AMCBankServMgt.GetLicenseNumber(), AMCBankServiceSetup."Sign-up URL") + '\\' +
                          StrSubstNo(UseDemoUserLbl, AMCBankServiceSetup.GetDemoUserName());
            error(Error_Text);
        end;

        //if demouser - always return demosolution
        if (AMCBankServiceSetup.GetUserName() = AMCBankServiceSetup.GetDemoUserName()) then begin
            AMCSolution := AMCBankServMgt.GetDemoSolutionCode();
            AMCBankServiceSetup.Solution := CopyStr(AMCSolution, 1, 50);
            AMCBankServMgt.SetURLsToDefault(AMCBankServiceSetup);
        end
        else
            if (CallLicenseServer) then
                AMCBoughtModule := GetModuleInfoFromWebservice(AMCSpecificURL, AMCSignUpURL, AMCSupportURL, AMCSolution, ShortTimeout);

        if (AMCSolution <> '') then begin
            AMCBankServiceSetup.Solution := CopyStr(AMCSolution, 1, 50);
            AMCBankServiceSetup.Modify();
            Commit(); //Need to commit, to make sure right solution is used after this point
        end;

        //First we update the URLs
        if (UpdURL) then begin
            if (URLSChanged) then begin
                AMCBankServiceSetup."Sign-up URL" := SignupURL;
                AMCBankServiceSetup."Service URL" := LowerCase(ServiceURL);
                AMCBankServiceSetup."Support URL" := SupportURL;
                AMCBankServiceSetup.MODIFY();
            end
            else begin
                if (UpperCase(AMCBankServiceSetup.Solution) <> 'ENTERPRISE') then
                    AMCBankServMgt.SetURLsToDefault(AMCBankServiceSetup);

                if ((AMCSpecificURL <> '') or (AMCSignUpURL <> '') or (AMCSupportURL <> '')) then begin
                    if ((AMCSpecificURL <> '') and (UpperCase(AMCBankServiceSetup.Solution) <> 'ENTERPRISE')) then
                        AMCBankServiceSetup."Service URL" := AMCBankServMgt.GetServiceURL(AMCSpecificURL, AMCBankServiceSetup."Namespace API Version");

                    if (AMCSignUpURL <> '') then
                        AMCBankServiceSetup."Sign-up URL" := CopyStr(AMCSignUpURL, 1, 250);

                    if (AMCSupportURL <> '') then
                        AMCBankServiceSetup."Support URL" := CopyStr(AMCSupportURL, 1, 250);

                    AMCBankServiceSetup.Modify();
                end;
            end;
            commit(); //Need to commit, to make sure right service URL is used after this point
        end;

        if (UpdDataExchDef) then begin
            if (UpdCreditTransfer) then
                DataExchDef_Filter += AMCBankServMgt.GetDataExchDef_CT() + ',';

            if (UpdateStatementImport) then
                DataExchDef_Filter += AMCBankServMgt.GetDataExchDef_STMT() + ',';

            if (UpdPositivePay) then
                DataExchDef_Filter += AMCBankServMgt.GetDataExchDef_PP() + ',';

            if (UpdCreditAdvice) then
                DataExchDef_Filter += AMCBankServMgt.GetDataExchDef_CREM();

            if (DataExchDef_Filter <> '') then
                BasisSetupRanOK := GetDataExchDefsFromWebservice(DataExchDef_Filter, ApplVer, BuildNo, LongTimeout, AMCBankServMgt.GetAppCaller());
        end;

        AMCBankServMgt.AMCBankInitializeBaseData();

        if (UpdBank) then
            AMCBankImpBankListHndl.GetBankListFromWebService(false, BankCountryCode, LongTimeout, AMCBankServMgt.GetAppCaller());

        if (UpdBankAccounts) then
            if (not TempOnlineBankAccLink.IsEmpty()) then begin
                TempOnlineBankAccLink.Reset();
                TempOnlineBankAccLink.SetCurrentKey("Automatic Logon Possible");
                TempOnlineBankAccLink.SetRange(TempOnlineBankAccLink."Automatic Logon Possible", true);
                if (TempOnlineBankAccLink.FindSet()) then
                    repeat
                        BankAccount.Reset();
                        if (BankAccount.get(TempOnlineBankAccLink."No.")) then begin
                            if (BankExportImportSetup.Get(AMCBankServMgt.GetDataExchDef_CT())) then
                                BankAccount."Payment Export Format" := AMCBankServMgt.GetDataExchDef_CT();

                            if (BankExportImportSetup.Get(AMCBankServMgt.GetDataExchDef_STMT())) then
                                BankAccount."Bank Statement Import Format" := AMCBankServMgt.GetDataExchDef_STMT();

                            if (BankAccount."Credit Transfer Msg. Nos." = '') then
                                BankAccount."Credit Transfer Msg. Nos." := AMCBankServMgt.GetDefaultCreditTransferMsgNo();

                            BankAccount.Modify();
                        end
                    until TempOnlineBankAccLink.Next() = 0
            end
            else begin
                BankAccount.Reset();
                BankAccount.SetRange(Blocked, false);
                if (BankAccount.FindSet()) then
                    repeat
                        if BankAccount."Payment Export Format" = '' then
                            if (BankExportImportSetup.Get(AMCBankServMgt.GetDataExchDef_CT())) then
                                BankAccount."Payment Export Format" := AMCBankServMgt.GetDataExchDef_CT();

                        if BankAccount."Bank Statement Import Format" = '' then
                            if (BankExportImportSetup.Get(AMCBankServMgt.GetDataExchDef_STMT())) then
                                BankAccount."Bank Statement Import Format" := AMCBankServMgt.GetDataExchDef_STMT();

                        if BankAccount."Payment Export Format" = AMCBankServMgt.GetDataExchDef_CT() then
                            if (BankAccount."Credit Transfer Msg. Nos." = '') then
                                BankAccount."Credit Transfer Msg. Nos." := AMCBankServMgt.GetDefaultCreditTransferMsgNo();

                        BankAccount.Modify();
                    until BankAccount.Next() = 0;
            end;

        exit(BasisSetupRanOK);
    end;

    [Obsolete('This method is obsolete. A new GetModuleInfoFromWebservice overload is available', '16.2')]
    procedure GetDataExchDefsFromWebservice(DataExchDefFilter: Text; ApplVersion: Text; BuildNumber: Text; Timeout: Integer): Boolean;
    var
        TempBlobRequestBody: Codeunit "Temp Blob";
    begin
        exit(GetDataExchDefsFromWebservice(DataExchDefFilter, ApplVersion, BuildNumber, Timeout, AMCBankServMgt.GetAppCaller()));
    end;

    procedure GetDataExchDefsFromWebservice(DataExchDefFilter: Text; ApplVersion: Text; BuildNumber: Text; Timeout: Integer; AppCaller: Text[30]): Boolean;
    var
        TempBlobRequestBody: Codeunit "Temp Blob";
    begin
        if (SendDataExchRequestToWebService(TempBlobRequestBody, true, Timeout, ApplVersion, BuildNumber, AppCaller)) then
            exit(GetDataExchangeData(TempBlobRequestBody, DataExchDefFilter))
        else
            exit(false)
    end;

    [Obsolete('This method is obsolete. A new GetModuleInfoFromWebservice overload is available', '16.0')]
    procedure GetModuleInfoFromWebservice(Var XTLUrl: Text; Var Solution: Text; Timeout: Integer): Boolean;
    var
        ModuleResponseMessage: HttpResponseMessage;
        SignUpUrl: Text;
        SupportUrl: Text;
    begin
        //Get reponse and XTLUrl and Solution
        exit(GetModuleInfoFromWebservice(XTLUrl, SignUpUrl, SupportUrl, Solution, Timeout));
    end;

    procedure GetModuleInfoFromWebservice(Var XTLUrl: Text; Var SignUpUrl: Text; var SupportUrl: Text; Var Solution: Text; Timeout: Integer): Boolean;
    var
        ModuleTempBlob: Codeunit "Temp Blob";
        ModuleRequestMessage: HttpRequestMessage;
        ModuleResponseMessage: HttpResponseMessage;
        Handled: Boolean;
        webcall: text;
    begin

        webcall := ModuleWebCallTxt;
        AMCBankServMgt.CheckCredentials();

        AMCBankServiceRequestMgt.InitializeHttp(ModuleRequestMessage, 'https://license.amcbanking.com/' + AMCBankServMgt.GetLicenseXmlApi(), 'POST');

        PrepareSOAPRequestBodyModuleCreate(ModuleRequestMessage);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(ModuleRequestMessage);

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, ModuleRequestMessage, ModuleResponseMessage, webcall, AMCBankServMgt.GetAppCaller(), true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(ModuleResponseMessage, ModuleTempBlob, webcall, false);
        exit(GetModuleInfoData(ModuleTempBlob, XTLUrl, SignUpUrl, SupportUrl, Solution, AMCBankServMgt.GetAppCaller())); //Get reponse and XTLUrl and Solution
    end;

    local procedure SendDataExchRequestToWebService(var TempBlobBody: Codeunit "Temp Blob"; EnableUI: Boolean; Timeout: Integer; ApplVersion: Text; BuildNumber: Text; AppCaller: Text[30]): Boolean
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        DataExchRequestMessage: HttpRequestMessage;
        DataExchResponseMessage: HttpResponseMessage;
        webcall: text;
        Handled: Boolean;
        Result: Text;
    begin
        webcall := DataExchangeWebCallTxt;
        AMCBankServMgt.CheckCredentials();
        AMCBankServiceSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(DataExchRequestMessage, AMCBankServiceSetup."Service URL", 'POST');

        PrepareSOAPRequestBodyDataExchangeDef(DataExchRequestMessage, ApplVersion, BuildNumber);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(DataExchRequestMessage);

        if not EnableUI then
            AMCBankServiceRequestMgt.DisableProgressDialog();

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.SetTimeout(Timeout);
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, DataExchRequestMessage, DataExchResponseMessage, webcall, AppCaller, true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(DataExchResponseMessage, TempBlobBody, webcall + AMCBankServiceRequestMgt.GetResponseTag(), true);
        if (AMCBankServiceRequestMgt.HasResponseErrors(TempBlobBody, AMCBankServiceRequestMgt.GetHeaderXPath(), webcall + AMCBankServiceRequestMgt.GetResponseTag(), Result, AppCaller)) then begin
            if (EnableUI) then
                AMCBankServiceRequestMgt.ShowResponseError(Result);

            exit(false)
        end
        else
            exit(true);
    end;

    local procedure PrepareSOAPRequestBodyModuleCreate(var BodyRequestMessage: HttpRequestMessage);
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        contentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        AmcWebServiceXMLElement: XmlElement;
        FunctionXmlElement: XmlElement;
        TempXmlDocText: Text;
        EncodPos: Integer;
        Application1: Text;
        Application1patch: Text;
        Application1Version: Text;
        Command: Text;
        Password: Text;
        Serialnumber: Text;
        System: Text;
    begin

        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankServiceSetup.Get();
        AmcWebServiceXMLElement := XmlElement.Create(ModuleWebCallTxt);
        AmcWebServiceXMLElement.SetAttribute('webservice', '1.0');

        Application1 := 'AMC-Banking';
        Application1patch := 'XXX';
        Application1Version := 'XXX';
        Command := 'module';
        Password := AMCBankServiceSetup.GetPassword();
        Serialnumber := COPYSTR(AMCBankServMgt.GetLicenseNumber(), 1, 50);
        System := 'Business Central';

        OnPrepareSOAPRequestBodyModuleCreate(Application1, Application1patch, Application1Version,
                                             Command, Password, Serialnumber, System);

        FunctionXmlElement := XmlElement.Create('function');
        FunctionXmlElement.SetAttribute('application1', Application1);
        FunctionXmlElement.SetAttribute('application1patch', Application1patch);
        FunctionXmlElement.SetAttribute('application1version', Application1Version);
        FunctionXmlElement.SetAttribute('command', Command);
        FunctionXmlElement.SetAttribute('password', Password);
        FunctionXmlElement.SetAttribute('serialnumber', Serialnumber);
        FunctionXmlElement.SetAttribute('system', System);

        AmcWebServiceXMLElement.Add(FunctionXmlElement);
        BodyContentXmlDoc.Add(AmcWebServiceXMLElement);
        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        //Licenseserver can not parse ' standalone="No"'
        EncodPos := StrPos(TempXmlDocText, ' standalone="No"');
        if (EncodPos > 0) THEN
            TempXmlDocText := DelStr(TempXmlDocText, EncodPos, STRLEN(' standalone="No"'));

        contentHttpContent.WriteFrom(TempXmlDocText);
        BodyRequestMessage.Content(contentHttpContent);

    end;

    [IntegrationEvent(false, false)]
    procedure OnPrepareSOAPRequestBodyModuleCreate(var Application1: Text; var Application1patch: Text; var Application1Version: Text;
                                                   var Command: Text; var Password: Text; var Serialnumber: Text; var System: Text)
    begin
    end;

    local procedure GetModuleInfoData(TempBlobResponse: Codeunit "Temp Blob"; Var XTLUrl: Text; Var SignupUrl: Text; Var SupportUrl: Text; Var Solution: Text; Appcaller: Text[30]): Boolean;
    var
        ResponseContent: HttpContent;
        XMLDocOut: XmlDocument;
        ModuleXMLNodeList: XmlNodeList;
        ModuleXMLNodeCount: Integer;
        ModuleIdXMLNode: XmlNode;
        ResultXMLNode: XmlNode;
        DataXMLAttributeCollection: XMLAttributeCollection;
        DataXmlAttribute: XmlAttribute;
        AttribCounter: Integer;
        ResponseInStr: InStream;
        XPath: Text;
        XResultPath: Text;
        ModuleName: Text;
        Erp: Text;
        Result: Text;
        ResultText: Text;
        ResultUrl: Text;
    begin

        TempBlobResponse.CreateInStream(ResponseInStr);
        XmlDocument.ReadFrom(ResponseInStr, XMLDocOut);
        ResponseContent.WriteFrom(ResponseInStr);

        XResultPath := 'amcwebservice//functionfeedback/header/answer';
        if (XMLDocOut.SelectSingleNode(XResultPath, ResultXMLNode)) then
            if (ResultXMLNode.AsXmlElement().HasAttributes()) then begin
                DataXMLAttributeCollection := ResultXMLNode.AsXmlElement().Attributes();
                for AttribCounter := 1 to DataXMLAttributeCollection.Count() do begin
                    DataXMLAttributeCollection.Get(AttribCounter, DataXmlAttribute);
                    if (DataXmlAttribute.Name() = 'result') then
                        Result += DataXmlAttribute.Value();
                end;
            end;
        if (Result <> 'ok') then begin
            ResultText := TryLoadErrorLbl;
            XResultPath := 'amcwebservice//functionfeedback/body/syslog';
            XMLDocOut.selectNodes(XResultPath, ModuleXMLNodeList);
            FOR ModuleXMLNodeCount := 1 TO ModuleXMLNodeList.Count() DO BEGIN
                ModuleXMLNodeList.Get(ModuleXMLNodeCount, ResultXMLNode);
                if (ResultXMLNode.AsXmlElement().HasAttributes()) then begin
                    DataXMLAttributeCollection := ResultXMLNode.AsXmlElement().Attributes();
                    for AttribCounter := 1 to DataXMLAttributeCollection.Count() do begin
                        DataXMLAttributeCollection.Get(AttribCounter, DataXmlAttribute);
                        if (DataXmlAttribute.Name() = 'errortext') then
                            if (ResultText <> '') then
                                ResultText += '\' + DataXmlAttribute.Value()
                            else
                                ResultText := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'url') then
                            if (ResultUrl <> '') then
                                ResultUrl += '\' + DataXmlAttribute.Value()
                            else
                                ResultUrl := DataXmlAttribute.Value();
                    end;
                end;
            end;
            AMCBankServiceRequestMgt.LogHttpActivity('amcwebservice', AppCaller, ResultText, '', ResultUrl, ResponseContent, Result);
            error(ResultText);
        end;

        XPath := 'amcwebservice//functionfeedback/body/package/sysusertable';
        XMLDocOut.selectNodes(XPath, ModuleXMLNodeList);
        IF ModuleXMLNodeList.Count() > 0 THEN
            FOR ModuleXMLNodeCount := 1 TO ModuleXMLNodeList.Count() DO BEGIN
                ModuleXMLNodeList.Get(ModuleXMLNodeCount, ModuleIdXMLNode);
                if (ModuleIdXMLNode.AsXmlElement().HasAttributes()) then begin
                    DataXMLAttributeCollection := ModuleIdXMLNode.AsXmlElement().Attributes();
                    for AttribCounter := 1 to DataXMLAttributeCollection.Count() do begin
                        DataXMLAttributeCollection.Get(AttribCounter, DataXmlAttribute);
                        if (DataXmlAttribute.Name() = 'item') then
                            ModuleName := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'xtlurl') then
                            XTLUrl := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'signupurl') then
                            SignupUrl := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'supporturl') then
                            SupportUrl := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'solution') then
                            Solution := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'erp') then
                            Erp := DataXmlAttribute.Value();
                    end;
                end;
                AMCBankServiceRequestMgt.LogHttpActivity('amcwebservice', AppCaller, Result, '', '', ResponseContent, Result);
                if ((LowerCase(ModuleName) = LowerCase('AMC-Banking')) and
                    (LowerCase(Erp) = LowerCase('Dyn. NAV'))) then
                    exit(true)
                else begin
                    ModuleName := '';
                    XTLUrl := '';
                    SignupUrl := '';
                    SupportUrl := '';
                    Solution := AMCBankServMgt.GetDemoSolutionCode();
                    Erp := '';
                end;
            end;

        exit(false);
    end;

    local procedure PrepareSOAPRequestBodyDataExchangeDef(var DataExchRequestMessage: HttpRequestMessage; ApplVersion: Text; BuildNumber: Text);
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        contentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        EnvelopeXMLElement: XmlElement;
        BodyXMLElement: XMLElement;
        OperationXmlNode: XMLElement;
        ChildXmlElement: XmlElement;
        TempXmlDocText: Text;
    begin
        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankingSetup.Get();
        AMCBankServiceRequestMgt.CreateEnvelope(BodyContentXmlDoc, EnvelopeXmlElement, AMCBankingSetup.GetUserName(), AMCBankingSetup.GetPassword(), '');
        AMCBankServiceRequestMgt.AddElement(EnvelopeXMLElement, EnvelopeXMLElement.NamespaceUri(), 'Body', '', BodyXMLElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(BodyXMLElement, AMCBankServMgt.GetNamespace(), 'dataExchange', '', OperationXmlNode, '', '', '');

        if (ApplVersion <> '') then begin
            AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'appl', ApplVersion, ChildXmlElement, '', '', '');
            AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'build', BuildNumber, ChildXmlElement, '', '', '');
        end
        else begin
            AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'appl', GetApplVersion(), ChildXmlElement, '', '', '');
            AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'build', GetBuildNumber(), ChildXmlElement, '', '', '');
        end;

        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        AMCBankServiceRequestMgt.RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        DataExchRequestMessage.Content(contentHttpContent);
    end;

    local procedure GetDataExchangeData(TempBlob: Codeunit "Temp Blob"; DataExchDefFilter: Text): Boolean;
    var
        TempBlobData: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        XMLDocOut: XmlDocument;
        DataExchXMLNodeList: XmlNodeList;
        DataExchXMLNodeCount: Integer;
        ResponseInStr: InStream;
        Base64OutStreamData: OutStream;
        ChildNode: XmlNode;

        DataExchDefCode: Code[20];
        Base64String: Text;
    begin
        TempBlob.CreateInStream(ResponseInStr);
        XmlDocument.ReadFrom(ResponseInStr, XMLDocOut);

        if (XMLDocOut.selectNodes(STRSUBSTNO(ReturnPathTxt, DataExchangeWebCallTxt + ResponseNodeTxt), DataExchXMLNodeList)) then
            IF DataExchXMLNodeList.Count() > 0 THEN
                FOR DataExchXMLNodeCount := 1 TO DataExchXMLNodeList.Count() DO begin
                    DataExchXMLNodeList.Get(DataExchXMLNodeCount, ChildNode);
                    CLEAR(DataExchDefCode);
                    CLEAR(TempBlobData);
                    DataExchDefCode := COPYSTR(AMCBankServiceRequestMgt.getNodeValue(ChildNode, './type'), 1, 20);
                    Base64String := AMCBankServiceRequestMgt.getNodeValue(ChildNode, './data');
                    TempBlobData.CreateOutStream(Base64OutStreamData);
                    Base64Convert.FromBase64(Base64String, Base64OutStreamData);
                    //READ DATA INTO TempBlobData
                    if ((TempBlobData.HasValue()) and (DataExchDefCode <> '') and
                        (StrPos(DataExchDefFilter, DataExchDefCode) <> 0)) then
                        ImportDataExchDef(DataExchDefCode, TempBlobData);

                end;
        exit(true);
    end;

    local procedure ImportDataExchDef(DataExchCode: Code[20]; TempBlob: Codeunit "Temp Blob");
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchDefInStream: InStream;
    begin

        if DataExchDef.GET(DataExchCode) then
            DataExchDef.DELETE(true);

        CLEAR(DataExchDef);
        TempBlob.CREATEINSTREAM(DataExchDefInStream);
        XMLPORT.IMPORT(XMLPORT::"Imp / Exp Data Exch Def & Map", DataExchDefInStream);

        CLEAR(DataExchDef);
        if DataExchDef.GET(DataExchCode) then
            InsertUpdateBankExportImport(DataExchCode, DataExchDef.Name);
    end;

    local procedure InsertUpdateBankExportImport(DataExchDefCode: Code[20]; DefName: Text[100])
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if (BankExportImportSetup.GET(DataExchDefCode)) then
            BankExportImportSetup.Delete();

        CASE DataExchDefCode OF
            AMCBankServMgt.GetDataExchDef_CT():
                WITH BankExportImportSetup DO BEGIN
                    INIT();
                    Code := DataExchDefCode;
                    Name := DefName;
                    Direction := BankExportImportSetup.Direction::Export;
                    "Processing Codeunit ID" := CODEUNIT::"AMC Bank Exp. CT Launcher";
                    "Processing XMLport ID" := 0;
                    "Check Export Codeunit" := 0;
                    "Preserve Non-Latin Characters" := TRUE;
                    "Data Exch. Def. Code" := AMCBankServMgt.GetDataExchDef_CT();
                    BankExportImportSetup.Insert();
                END;
            AMCBankServMgt.GetDataExchDef_STMT():
                WITH BankExportImportSetup DO BEGIN
                    INIT();
                    Code := DataExchDefCode;
                    Name := DefName;
                    Direction := BankExportImportSetup.Direction::Import;
                    "Processing Codeunit ID" := CODEUNIT::"AMC Bank Exp. CT Launcher";
                    "Processing XMLport ID" := 0;
                    "Check Export Codeunit" := 0;
                    "Preserve Non-Latin Characters" := TRUE;
                    "Data Exch. Def. Code" := AMCBankServMgt.GetDataExchDef_STMT();
                    BankExportImportSetup.Insert();
                END;
        END
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetApplVersion(var ApplVersion: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetBuildNumber(var BuildNumber: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnOpenAssistedSetupPage(var BankDataConvServPPVisible: Boolean; var BankDataConvServCREMVisible: Boolean; var UpdPayMethVisible: Boolean; var UpdBankClearStdVisible: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    //To update extra things that standard does not.
    [Obsolete('This IntegrationEvent is obsolete. A new OnAfterRunBasisSetupV16 IntegrationEvent is available, with the an extra parameters (TempOnlineBankAccLink: Record "Online Bank Acc. Link") to control which bank account should be updated.', '16.0')]
    procedure OnAfterRunBasisSetup(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                                   UpdBank: Boolean; UpdPayMeth: Boolean; CountryCode: Code[10]; PaymCountryCode: Code[10];
                                   UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean;
                                   UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                                   UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; CallLicenseServer: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterRunBasisSetupV16(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                                   UpdBank: Boolean; UpdPayMeth: Boolean; BankCountryCode: Code[10]; PaymCountryCode: Code[10];
                                   UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean;
                                   UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                                   UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; var TempOnlineBankAccLink: Record "Online Bank Acc. Link"; CallLicenseServer: Boolean)
    begin
    end;

    procedure DisplayAssistedSetupWizard(AssistedSetupNotification: Notification)
    var
        AMCBankAssistedSetup: Page "AMC Bank Assisted Setup";
    begin
        AMCBankAssistedSetup.Run();
    end;

    procedure DisplayAMCBankSetup(AssistedSetupNotification: Notification)
    var
        AMCBankingSetup: Page "AMC Banking Setup";
    begin
        AMCBankingSetup.Run();
    end;

    procedure UpgradeNotificationIsNeeded(DataExchDefCode: Code[20]): Boolean
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if (BankExportImportSetup.Get(DataExchDefCode)) then
            if (BankExportImportSetup."Processing Codeunit ID" = Codeunit::"AMC Bank Upg. Notification") then
                exit(true);

        exit(false);
    end;

    procedure GetBankExportNotificationId(DataExchDefCode: Code[20]): Guid
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if (BankExportImportSetup.Get(DataExchDefCode)) then
            exit(BankExportImportSetup.SystemId);

        exit(CreateGuid());
    end;

    local procedure CallAssistedSetupNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin
        Notification.Id := NotificationId;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Message := AssistedSetupNeededNotificationTxt;
        Notification.AddAction(AssistedSetupNotificationActionTxt, Codeunit::"AMC Bank Assisted Mgt.", 'DisplayAssistedSetupWizard');
        Notification.Send();
    end;

    local procedure CallDemoSolutionNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin
        if IsDemoSolutionNotificationEnabled(NotificationId) then begin
            Notification.Id := NotificationId;
            Notification.Scope := NotificationScope::LocalScope;
            Notification.Message := DemoSolutionNotificationTxt;
            Notification.AddAction(DemoSolutionNotificationActionTxt, Codeunit::"AMC Bank Assisted Mgt.", 'DisplayAMCBankSetup');
            Notification.AddAction(DontShowThisAgainMsg, Codeunit::"AMC Bank Assisted Mgt.", 'DisableDemoSolutionNotification');
            Notification.Send();
        end;
    end;

    procedure IsDemoSolutionNotificationEnabled(NotificationId: GUID): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        if MyNotifications.Disable(NotificationId) then
            exit(false);

        exit(true);
    end;

    procedure EnableDemoSolutionNotification(NotificationId: GUID)
    var
        MyNotifications: Record "My Notifications";
    begin
        if MyNotifications.Disable(NotificationId) then
            MyNotifications.SetStatus(NotificationId, true);
    end;

    procedure DisableDemoSolutionNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(Notification.Id()) then
            MyNotifications.InsertDefault(Notification.Id(), DemoSolutionNotificationNameTok, DemoSolutionNotificationDescTok, false);
    end;

    [EventSubscriber(ObjectType::Page, Page::"AMC Banking Setup", 'OnOpenPageEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationAMCBankingSetup(var rec: Record "AMC Banking Setup")
    var

    begin
        if (UpgradeNotificationIsNeeded(AMCBankServMgt.GetDataExchDef_CT()) or
            UpgradeNotificationIsNeeded(AMCBankServMgt.GetDataExchDef_STMT())) then
            CallAssistedSetupNotification(rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"AMC Bank Bank Name List", 'OnOpenPageEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationAMCBankBanks(var rec: Record "AMC Bank Banks")
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.get();
        if (UpgradeNotificationIsNeeded(AMCBankServMgt.GetDataExchDef_CT()) or
            UpgradeNotificationIsNeeded(AMCBankServMgt.GetDataExchDef_STMT())) then
            CallAssistedSetupNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Journal", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPaymentJournal(var Rec: Record "Gen. Journal Line")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (GenJournalBatch.Get(Rec."Journal Template Name", rec."Journal Batch Name")) then
            if (GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account") then
                if (BankAccount.get(GenJournalBatch."Bal. Account No.")) then
                    if (UpgradeNotificationIsNeeded(BankAccount."Payment Export Format")) then begin
                        CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Payment Export Format"));
                        exit;
                    end;

        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (GenJournalBatch.Get(Rec."Journal Template Name", rec."Journal Batch Name")) then
                if (GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account") then
                    if (BankAccount.get(GenJournalBatch."Bal. Account No.")) then
                        if ((BankAccount."Payment Export Format" = AMCBankServMgt.GetDataExchDef_CT()) and
                           (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                            CallDemoSolutionNotification(GetBankExportNotificationId(BankAccount."Payment Export Format"));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Pmt. Reconciliation Journals", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPmtReconJours(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (BankAccount.get(rec."Bank Account No.")) then
            if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                exit;
            end;

        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (BankAccount.get(rec."Bank Account No.")) then
                if ((BankAccount."Bank Statement Import Format" = AMCBankServMgt.GetDataExchDef_STMT()) and
                    (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                    CallDemoSolutionNotification(AMCBankingSetup.SystemId);
    end;


    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPaymntReconJour(var Rec: Record "Bank Acc. Reconciliation Line")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (BankAccount.get(rec."Bank Account No.")) then
            if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                exit;
            end;
        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (BankAccount.get(rec."Bank Account No.")) then
                if ((BankAccount."Bank Statement Import Format" = AMCBankServMgt.GetDataExchDef_STMT()) and
                   (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                    CallDemoSolutionNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Acc. Reconciliation List", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankAccReconList(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (BankAccount.get(rec."Bank Account No.")) then
            if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                exit;
            end;

        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (BankAccount.get(rec."Bank Account No.")) then
                if ((BankAccount."Bank Statement Import Format" = AMCBankServMgt.GetDataExchDef_STMT()) and
                   (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                    CallDemoSolutionNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Acc. Reconciliation", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankAccRecon(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (BankAccount.get(rec."Bank Account No.")) then
            if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                exit;
            end;

        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (BankAccount.get(rec."Bank Account No.")) then
                if ((BankAccount."Bank Statement Import Format" = AMCBankServMgt.GetDataExchDef_STMT()) and
                   (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                    CallDemoSolutionNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Export/Import Setup", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankExportImportSetup(var Rec: Record "Bank Export/Import Setup")
    var
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (UpgradeNotificationIsNeeded(Rec.Code)) then
            CallAssistedSetupNotification(Rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        AmcBankingSetup: Record "AMC Banking Setup";
        BaseAppID: Codeunit "BaseApp ID";
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        AssistedSetup.Add(BaseAppID.Get(), Page::"AMC Bank Assisted Setup", AssistedSetupTxt, AssistedSetupGroup::ReadyForBusiness, '', VideoCategory::ReadyForBusiness, AssistedSetupHelpTxt, AssistedSetupDescriptionTxt);
        if AmcBankingSetup.Get() then
            AssistedSetup.Complete(Page::"AMC Bank Assisted Setup");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnAfterRun', '', true, true)]
    local procedure UpdateAssistedSetupStatus(ExtensionID: Guid; PageID: Integer)
    var
        AmcBankingSetup: Record "AMC Banking Setup";
        AssistedSetup: Codeunit "Assisted Setup";
        BaseAppID: Codeunit "BaseApp ID";
    begin
        if ExtensionId <> BaseAppID.Get() then
            exit;
        if PageID <> Page::"AMC Bank Assisted Setup" then
            exit;
        if AmcBankingSetup.Get() then
            AssistedSetup.Complete(PageID);
    end;

}

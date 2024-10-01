codeunit 11000053 "Digipoort SaaS Communication" implements "DigiPoort Communication"
{
    Access = Internal;

    var
        ClientIDLbl: label 'AppNetProxyFnClientID', Locked = true;
        ClientSecretLbl: label 'AppNetProxyFnClientSecret', Locked = true;
        ResourceUrLLbl: label 'AppNetProxyFnResourceUrL', Locked = true;
        EndpointLbl: Label 'AppNetProxyFnEndpoint', Locked = true;
        AuthURlLbl: Label 'AppNetProxyFnAuthUrl', Locked = true;
        FunctionSecretErr: Label 'There was an error connecting to the service.';
        DigipoortTok: Label 'DigipoortTelemetryCategoryTok', Locked = true;
        ResponseErr: Label 'There was an error while connecting to the service. Error message: %1', Comment = '%1=Error message';
        RequestSuccessfulMsg: label 'Digiport request was submitted successfully', Locked = true;
        RequestFailedMsg: label 'Digiport request failed with reason: %1, and error message: %2', Locked = true;
        SecretsMissingMsg: label 'Digiport Az Function secrets are  missing', Locked = true;

    [NonDebuggable]
    procedure Deliver(Request: DotNet aanleverRequest; var Response: DotNet aanleverResponse; RequestUrl: Text; ClientCertificateBase64: Text; DotNetSecureString: Codeunit DotNet_SecureString; ServiceCertificateBase64: Text; Timeout: Integer; UseCertificateSetup: boolean)
    var
        DigipoortServices: DotNet DigipoortServices;
        RequestBody, TxtResponse : Text;
    begin
        RequestBody := DigipoortServices.SerializeDeliverRequest(Request,
            RequestUrl,
            ClientCertificateBase64,
            DotNetSecureString.GetPlainText(),
            ServiceCertificateBase64,
            Timeout);

        TxtResponse := CommunicateWithAzureFunction('api/Deliver', RequestBody);
        Response := DigipoortServices.DeserializeDeliverResponse(TxtResponse);
    end;

    [NonDebuggable]
    procedure GetStatus(Request: DotNet getStatussenProcesRequest; var StatusResultatQueue: DotNet Queue; ResponseUrl: Text; ClientCertificateBase64: Text; DotNetSecureString: Codeunit DotNet_SecureString; ServiceCertificateBase64: Text; Timeout: Integer; UseCertificateSetup: boolean)
    var
        DigipoortServices: DotNet DigipoortServices;
        RequestBody, TxtResponse : Text;
    begin
        RequestBody := DigipoortServices.SerializeGetStatusRequest(Request,
            ResponseUrl,
            ClientCertificateBase64,
            DotNetSecureString.GetPlainText(),
            ServiceCertificateBase64,
            Timeout);

        TxtResponse := CommunicateWithAzureFunction('api/GetStatus', RequestBody);
        StatusResultatQueue := DigipoortServices.DeserializeGetStatusResponse(TxtResponse);
    end;

    [NonDebuggable]
    local procedure CommunicateWithAzureFunction(Path: Text; Body: Text): Text
    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        IAzurefunctionAuthentication: Interface "Azure Functions Authentication";
        Response, ErrorMsg : Text;
        ClientID, ClientSecret, ResourceUrL, Endpoint, AuthUrl : Text;
    begin
        GetAzFunctionSecrets(ClientID, ClientSecret, ResourceUrL, Endpoint, AuthUrl);
        IAzurefunctionAuthentication := AzureFunctionsAuthentication.CreateOAuth2(GetEndpoint(Endpoint, Path), '', ClientID, ClientSecret, AuthUrl, '', ResourceUrL);

        AzureFunctionsResponse := AzureFunctions.SendPostRequest(IAzurefunctionAuthentication, Body, 'application/json');

        if AzureFunctionsResponse.IsSuccessful() then begin
            AzureFunctionsResponse.GetResultAsText(Response);
            Session.LogMessage('0000JP0', RequestSuccessfulMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DigipoortTok);
            exit(Response)
        end else begin
            AzureFunctionsResponse.GetError(ErrorMsg);
            Session.LogMessage('0000JP1', StrSubstNo(RequestFailedMsg, AzureFunctionsResponse.GetError(), ErrorMsg), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DigipoortTok);
            Error(ResponseErr, AzureFunctionsResponse.GetError());
        end;
    end;

    [NonDebuggable]
    local procedure GetAzFunctionSecrets(var ClientID: Text; var ClientSecret: Text; var ResourceUrL: Text; var Endpoint: Text; var AuthUrl: Text)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not (AzureKeyVault.GetAzureKeyVaultSecret(ClientIDLbl, ClientID)
            and AzureKeyVault.GetAzureKeyVaultSecret(ClientSecretLbl, ClientSecret)
            and AzureKeyVault.GetAzureKeyVaultSecret(ResourceUrLLbl, ResourceUrL)
            and AzureKeyVault.GetAzureKeyVaultSecret(AuthURlLbl, AuthUrl)
            and AzureKeyVault.GetAzureKeyVaultSecret(EndpointLbl, Endpoint)) then begin
            Session.LogMessage('0000JP2', SecretsMissingMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DigipoortTok);
            Error(FunctionSecretErr);
        end;
    end;

    local procedure GetEndpoint(Host: Text; Path: Text): text
    var
        URIBuilder: Codeunit "Uri Builder";
        URI: Codeunit URI;
    begin
        URIBuilder.Init(Host);
        URIBuilder.SetPath(Path);
        URIBuilder.GetUri(URI);
        exit(URI.GetAbsoluteUri());
    end;
}
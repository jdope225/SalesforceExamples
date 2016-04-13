public class EmbeddedDocuSignCont {
    public String response {get;set;}
    public String request {get;set;}
    public String iFrameUrl {get;set;}
    public boolean showIFrame {get;set;}
    public String envelopeStatus {get;set;}
    public String recipientName {get;set;}
    public String recipientEmail {get;set;}
    public String templateId {get;set;}
    public String roleName {get;set;}
    public String integratorKey {get;set;}
    public String username {get;set;}
    public String password {get;set;}
    
    public String baseUrl = '';
    public String accountId = '';
    public String url = '';  //endpoint url
    public String body = '';
    public String envelopeId = '';
    public String uri; //signature uri
    
    public String authenticationHeader{
        get{
            return 
                '<DocuSignCredentials>' + 
                  '<Username>' + username + '</Username>' +
                    '<Password>' + password + '</Password>' + 
                    '<IntegratorKey>' + integratorKey + '</IntegratorKey>' + 
                '</DocuSignCredentials>';
    }
        set;
    }
    
    public EmbeddedDocuSignCont(){
        initializePage();
        showIFrame = false;
    }
    
    public PageReference signDocument(){
        login();
        createSignRequest();
        return showEmbeddedView();
    }
    
    public PageReference login(){
        response = '';
        url = 'https://demo.docusign.net/restapi/v2/login_information';
        body = '';
        HTTPResponse resp = httphandler(url, 'GET', body, authenticationHeader);
        response = resp.getBody();
        
        DOM.Document doc = new DOM.Document();
        doc.load(resp.getBody());
        DOM.XmlNode root = doc.getRootElement();
        baseUrl = findXMLValue (root, 'baseUrl');
        accountId = findXMLValue (root, 'accountId');
        return null;
    }
    
    public PageReference createSignRequest(){
        url = baseUrl + '/envelopes';
        body =
            '<envelopeDefinition xmlns=\"http://www.docusign.com/restapi\">' +
            '<accountId>' + accountId + '</accountId>' +
            '<status>sent</status>' +
            '<emailSubject>DocuSign API Call - Signature request from template</emailSubject>' +
            '<templateId>' + templateId + '</templateId>' +
            '<templateRoles>' +
            '<templateRole>' +
            '<email>' + recipientEmail + '</email>' +
            '<name>' + recipientName + '</name>' +
            '<roleName>' + roleName + '</roleName>' +
            '<clientUserId>1001</clientUserId>' +
            '</templateRole>' + 
            '</templateRoles>' + 
            '</envelopeDefinition>';
        httpResponse resp = httphandler(url, 'POST', body, authenticationHeader);
        
        DOM.Document doc = new DOM.Document();
        doc.load(resp.getBody());
        DOM.XmlNode root = doc.getRootElement();
        uri = findXMLValue (root, 'uri');
        envelopeId = findXMLValue(root, 'envelopeId');
        
        response = resp.getBody();
        return null;
    }
    
    public PageReference showEmbeddedView(){
        url = baseUrl + uri + '/views/recipient';
        body = 
            '<recipientViewRequest xmlns=\"http://www.docusign.com/restapi\">'  +
            '<authenticationMethod>email</authenticationMethod>' +
            '<email>' + recipientEmail + '</email>' +
            '<returnUrl>http://www.docusign.com/devcenter</returnUrl>' +
            '<clientUserId>1001</clientUserId>' +
            '<userName>' + recipientName + '</userName>' +
            '</recipientViewRequest>';
        httpResponse resp = httphandler(url, 'POST', body, authenticationHeader);
        
        DOM.Document doc = new DOM.Document();
        doc.load(resp.getBody());
        DOM.XmlNode root = doc.getRootElement();
        iFrameUrl = findXMLValue (root, 'url');
        showIFrame = true;
        
        return null;
    }
    
    public PageReference showEnvelopeStatus(){
        url = baseUrl + '/envelopes?envelopeId=' + envelopeId;
        httpResponse resp = httphandler(url, 'GET', body, authenticationHeader);
        response = resp.getBody();
        
        DOM.Document doc = new DOM.Document();
        doc.load(resp.getBody());
        DOM.XmlNode root = doc.getRootElement();
        envelopeStatus = findXMLValue(root, 'status');
        return null;
    }
    
    public PageReference showSignedDocuments(){
        //url = baseUrl + '/envelopes/' + envelopeId +'/documents/combined';
        url = baseUrl + '/envelopes/' + envelopeId +'/documents';
        body = '';
        httpResponse resp = httphandler(url, 'GET', body, authenticationHeader);
        response = resp.getBody();
        /*
        DOM.Document doc = new DOM.Document();
        doc.load(resp.getBody());
        DOM.XmlNode root = doc.getRootElement();
        envelopeStatus = findXMLValue(root, 'uri');
    */
        return null;
    }
    
    /* Utility Methods */
    private HTTPResponse httpHandler(String url, String method, String body, String AuthHeader){
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setHeader('X-DocuSign-Authentication', AuthHeader);
        req.setHeader('Content-Type', 'application/xml');
        req.setHeader('Accept', 'application/xml');
        if (method.equalsIgnoreCase('POST')){
            req.setHeader('Content-Length', String.valueOf(body.length()));
            req.setBody(body);
        }
        return h.send(req);
    }
    
    private String findXMLValue(DOM.XMLNode node, String elementName) {
        String result = '';
          if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
              if(node.getName() == elementName){
                  result += node.getText().trim();
              }
            for (Dom.XMLNode child: node.getChildElements()) {
                result += findXMLValue(child, elementName);
            }
            return result;
          }
          return '';  //no element found
        }
    
    private void initializePage(){
        integratorKey  = 'BLUE-0b83afca-c365-489c-80b4-db238c5ebe8c';
        username    = '08d02034-3ac8-45a3-b3a4-462405e87dcb';
        password    = '3iF7EfYoBS50';
        recipientName   = 'Joe Doperalski';
        recipientEmail  = 'joe.doperalski@gmail.com';
        templateId    = '5EC26FAF-6A0B-4FFB-B05D-53C185F9BC61';
        roleName    = 'Signer';

    }

}
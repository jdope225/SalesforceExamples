public class AddressCont {
    private final String USERID = '009JDOPE7486';
    private final String DESCRIPTION_USPS = '-- (USPS Suggestion)';
    private final String DESCRIPTION_USER = '-- (The Address You Entered)';
    private Contact c;
    public String response {get;set;}
    public String request {get;set;}
    public String selectedUSPSAddress {get;set;}
    public List<USPSAddress> USPSList = new List<USPSAddress>();
    
    public List<SelectOption> USPSAddresses{
        get{
                List<SelectOption> options = new List<SelectOption>();
                String s = '';
                for (USPSAddress a : USPSList) {
                    s = a.Address1 + ' ' + a.City + ' ' + a.state + ' ' + a.zip5 + '-' + a.zip4 + ' ' + a.description ;           
                    options.add(new SelectOption(a.Id, s));
                }
                return options;
            }
    }
    
    public AddressCont(ApexPages.StandardController controller){
        c = (contact)controller.getRecord();
    }
    
    public PageReference updateAddress(){
    return null;
    }
    
    public PageReference checkAddress(){
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(buildRequest());
        req.setEndpoint('callout:USPS');
        
        HTTPResponse resp = h.send(req);
        request = req.getBody();
        response = resp.getBody();
        
        parseResponse(resp);
        
        //add the user entered address to the list...
        USPSAddress a = new USPSAddress();
        a.USPSId = null;
        a.address1 = c.MailingStreet;
        a.city = c.MailingCity;
        a.state = c.MailingState;
        a.zip5 = c.MailingPostalCode;
        a.description = DESCRIPTION_USER;
        USPSList.add(a);
        
        return null;
    }
    
    private String buildRequest(){
        String body = '';
        body  = 'API=Verify&XML=';
        body += '<AddressValidateRequest USERID="' + USERID + '">';
        body += '<Address ID="1">';
        body += '<Address1></Address1>';
        body += '<Address2>' + c.MailingStreet +  '</Address2>' ;
        body += '<City>' + c.MailingCity + '</City>';
        body += '<State>' + c.MailingState + '</State>';
        body += '<Zip5>' + c.MailingPostalCode + '</Zip5>';
        body += '<Zip4></Zip4>';
        body += '</Address>';
        body += '</AddressValidateRequest>';
        return body;
    }
    private void parseResponse(HTTPResponse r){
        USPSList.clear();
        Dom.Document docx = new Dom.Document();
        docx.load(r.getBody());
        dom.XmlNode xroot = docx.getRootElement(); // <AddressvalidateResponse>
        for(Dom.XmlNode child: xroot.getChildElements()){ //child = <Address>
            USPSAddress a = new USPSAddress();
            a.USPSId = child.getAttributeValue(child.getAttributeKeyAt(0), child.getAttributeKeyNsAt(0));
            //a.address1 = child.getChildElement('Address1', null).getText(); //need to check when null...
            a.address1 = child.getChildElement('Address2', null).getText();
            a.city = child.getChildElement('City', null).getText();
            a.state = child.getChildElement('State', null).getText();
            a.zip5 = child.getChildElement('Zip5', null).getText();
            a.zip4 = child.getChildElement('Zip4', null).getText();
            a.description = DESCRIPTION_USPS;
            USPSList.add(a);
        }
        
    }
    
    private class USPSAddress{
        private String USPSId {get;set;}
        private String Id {get; private set;}
        private String address1 {get;set;}
        private String address2 {get;set;}
        private String city {get;set;}
        private String state {get;set;}
        private String zip5 {get;set;}
        private String zip4 {get;set;}
        private String description {get;set;}
        
        public USPSAddress(){
            Id = String.valueOf(Math.abs(Crypto.getRandomLong()));
        }
        public USPSAddress(String id, String a1, String a2, String c, String s, String z5, String z4){
            this.USPSId = id;
            this.address1 = a1;
            this.address2 = a2;
            this.city = c;
            this.state = s;
            this.zip5 = z5;
            this.zip4 = z4;
        }
        
    }

}
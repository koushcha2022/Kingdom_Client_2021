public class AccountReplicationRestMock implements HttpCalloutMock {

    //Implement Respond Method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HTTPResponse resp = new HTTPResponse();

        // Set response values, and return response.
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{"access_token":"Fake_Response_Token", "instance_url":"https://kb2021-dev-ed.lightning.force.com/lightning/" }');
        resp.setStatusCode(200);
        return resp;
    }
}

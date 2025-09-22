@isTest
public class WeatherServiceTest {

    @TestSetup
    static void makeData() {
        Account testAccount = new Account(
            Name = 'Test Account',
            ShippingCity = 'San Francisco'
        );
        insert testAccount;

        Weather_API_Settings__c settings = new Weather_API_Settings__c();
        settings.API_Key__c = 'test-api-key-123';
        insert settings;
    }

    @isTest
    static void testGetWeatherForCitySuccess() {
        Test.setMock(HttpCalloutMock.class, new WeatherServiceMockSuccess());

        Test.startTest();
        WeatherService.WeatherResponse response = WeatherService.getWeatherForCity('San Francisco');
        Test.stopTest();

        Assert.isTrue(response.success, 'Weather response should be successful');
        Assert.areEqual('San Francisco', response.city, 'City should match');
        Assert.areEqual(72.5, response.temperature, 'Temperature should match mock response');
        Assert.areEqual('Feels like 74°F', response.description, 'Description should match feels_like format');
    }

    @isTest
    static void testGetWeatherForCityEmptyCity() {
        Test.startTest();
        WeatherService.WeatherResponse response = WeatherService.getWeatherForCity('');
        Test.stopTest();

        Assert.isFalse(response.success, 'Response should not be successful');
        Assert.areEqual('City name cannot be empty', response.errorMessage, 'Error message should match');
    }

    @isTest
    static void testGetWeatherForCityNoApiKey() {
        delete [SELECT Id FROM Weather_API_Settings__c];

        Test.startTest();
        WeatherService.WeatherResponse response = WeatherService.getWeatherForCity('San Francisco');
        Test.stopTest();

        Assert.isFalse(response.success, 'Response should not be successful');
        Assert.isTrue(response.errorMessage.contains('API key not configured'), 'Error message should mention API key');
    }

    @isTest
    static void testGetWeatherForCityApiError() {
        Test.setMock(HttpCalloutMock.class, new WeatherServiceMockError());

        Test.startTest();
        WeatherService.WeatherResponse response = WeatherService.getWeatherForCity('San Francisco');
        Test.stopTest();

        Assert.isFalse(response.success, 'Response should not be successful');
        Assert.isTrue(response.errorMessage.contains('Weather API returned error'), 'Error message should mention API error');
    }

    @isTest
    static void testGetWeatherForAccountSuccess() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new WeatherServiceMockSuccess());

        Test.startTest();
        WeatherService.WeatherResponse response = WeatherService.getWeatherForAccount(testAccount.Id);
        Test.stopTest();

        Assert.isTrue(response.success, 'Weather response should be successful');
        Assert.areEqual('San Francisco', response.city, 'City should match account shipping city');
    }

    @isTest
    static void testGetWeatherForAccountNoShippingCity() {
        Account testAccount = new Account(Name = 'No City Account');
        insert testAccount;

        Test.startTest();
        WeatherService.WeatherResponse response = WeatherService.getWeatherForAccount(testAccount.Id);
        Test.stopTest();

        Assert.isFalse(response.success, 'Response should not be successful');
        Assert.isTrue(response.errorMessage.contains('shipping city'), 'Error message should mention shipping city');
    }

    @isTest
    static void testGetWeatherForAccountInvalidId() {
        Test.startTest();
        WeatherService.WeatherResponse response = WeatherService.getWeatherForAccount(null);
        Test.stopTest();

        Assert.isFalse(response.success, 'Response should not be successful');
        Assert.areEqual('Account ID cannot be null', response.errorMessage, 'Error message should match');
    }

    public class WeatherServiceMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"temperature": 72.5, "feels_like": 74.0}');
            response.setStatusCode(200);
            return response;
        }
    }

    public class WeatherServiceMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"error": "City not found"}');
            response.setStatusCode(404);
            response.setStatus('Not Found');
            return response;
        }
    }
}
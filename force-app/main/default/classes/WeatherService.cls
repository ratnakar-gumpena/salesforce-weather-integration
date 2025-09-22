public with sharing class WeatherService {

    public class WeatherResponse {
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public Decimal temperature { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static WeatherResponse getWeatherForCity(String city) {
        WeatherResponse response = new WeatherResponse();
        response.city = city;
        response.success = false;

        if (String.isBlank(city)) {
            response.errorMessage = 'City name cannot be empty';
            return response;
        }

        try {
            Weather_API_Settings__c settings = Weather_API_Settings__c.getInstance();
            if (settings == null || String.isBlank(settings.API_Key__c)) {
                response.errorMessage = 'Weather API key not configured in Custom Settings';
                return response;
            }

            // Use Elastic Beanstalk API endpoint
            String endpoint = 'http://WeatherDashboard-env.eba-ai4q4ugm.us-east-1.elasticbeanstalk.com/api/weather/' + EncodingUtil.urlEncode(city, 'UTF-8') + '?apikey=' + EncodingUtil.urlEncode(settings.API_Key__c, 'UTF-8');

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(10000);

            Http http = new Http();
            HttpResponse httpResponse = http.send(request);


            if (httpResponse.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());

                if (jsonResponse.containsKey('temperature')) {
                    response.temperature = (Decimal) jsonResponse.get('temperature');
                    // API provides feels_like, convert to description
                    Decimal feelsLike = (Decimal) jsonResponse.get('feels_like');
                    response.description = 'Feels like ' + Math.round(feelsLike) + '°C';
                    response.success = true;
                } else {
                    response.errorMessage = 'Invalid response format from weather API';
                }
            } else if (httpResponse.getStatusCode() == 301 || httpResponse.getStatusCode() == 302) {
                String redirectLocation = httpResponse.getHeader('Location');
                response.errorMessage = 'API redirect detected. Check Named Credential URL. Redirect to: ' + redirectLocation;
            } else {
                response.errorMessage = 'Weather API returned error: ' + httpResponse.getStatus() + ' (' + httpResponse.getStatusCode() + ')';
            }

        } catch (Exception e) {
            response.errorMessage = 'Error retrieving weather data: ' + e.getMessage();
        }

        return response;
    }

    @AuraEnabled(cacheable=true)
    public static WeatherResponse getWeatherForAccount(Id accountId) {
        WeatherResponse response = new WeatherResponse();
        response.success = false;

        if (accountId == null) {
            response.errorMessage = 'Account ID cannot be null';
            return response;
        }

        try {
            Account account = [SELECT ShippingCity FROM Account WHERE Id = :accountId LIMIT 1];

            if (String.isBlank(account.ShippingCity)) {
                response.errorMessage = 'Account does not have a shipping city specified';
                return response;
            }

            return getWeatherForCity(account.ShippingCity);

        } catch (QueryException e) {
            response.errorMessage = 'Account not found';
            return response;
        } catch (Exception e) {
            response.errorMessage = 'Error retrieving account data: ' + e.getMessage();
            return response;
        }
    }

}
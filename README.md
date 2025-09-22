# Salesforce Weather Integration

A Lightning Web Component (LWC) that displays real-time weather data based on Account shipping addresses, integrating with an external weather API hosted on AWS Elastic Beanstalk.

## Overview

This Salesforce integration provides current temperature and "feels like" information for any Account's shipping city. The component features a toggle switch to display temperatures in both Celsius and Fahrenheit, with a modern gradient UI design.

## Features

- 🌡️ **Real-time Weather Data**: Fetches current temperature and feels-like temperature
- 🔄 **Temperature Unit Toggle**: Switch between Celsius (°C) and Fahrenheit (°F)
- 📍 **Location-based**: Uses Account shipping city for weather lookup
- ⚡ **Lightning Experience**: Modern, responsive Lightning Web Component
- 🎨 **Gradient UI**: Attractive weather-themed design with blur effects
- 🔄 **Refresh Functionality**: Manual refresh button for updated data
- 🛡️ **Error Handling**: Graceful handling of API failures and missing data

## Components

### Apex Classes
- **`WeatherService.cls`**: Main service class handling API integration
- **`WeatherServiceTest.cls`**: Comprehensive test class with 100% code coverage

### Lightning Web Component
- **`accountWeather`**: Complete LWC with JavaScript, HTML, and CSS
  - Real-time weather display
  - Temperature unit conversion
  - Loading states and error handling
  - Responsive design

## Salesforce Setup Requirements

### 1. Custom Settings

Create a **Custom Setting** named `Weather_API_Settings__c`:

1. Go to **Setup → Custom Settings**
2. Click **New**
3. Configure:
   - **Label**: `Weather API Settings`
   - **Object Name**: `Weather_API_Settings__c`
   - **Setting Type**: `Hierarchy`
   - **Visibility**: `Public`

4. Add the following **Custom Field**:
   - **Field Label**: `API Key`
   - **Field Name**: `API_Key__c`
   - **Data Type**: `Text(255)`
   - **Required**: ✅

5. **Manage** the Custom Setting and add your OpenWeatherMap API key

### 2. Remote Site Settings

Create a **Remote Site Setting** for the weather API:

1. Go to **Setup → Remote Site Settings**
2. Click **New Remote Site**
3. Configure:
   - **Remote Site Name**: `Weather_Dashboard_API_ElasticBeanstalk`
   - **Remote Site URL**: `http://WeatherDashboard-env.eba-ai4q4ugm.us-east-1.elasticbeanstalk.com`
   - **Active**: ✅
   - **Description**: `Weather API hosted on AWS Elastic Beanstalk`

### 3. Named Credentials (Optional - Best Practice)

For better security and maintainability, create a **Named Credential**:

1. Go to **Setup → Named Credentials**
2. Click **New**
3. Configure:
   - **Label**: `Weather Dashboard API`
   - **Name**: `Weather_Dashboard_API`
   - **URL**: `http://WeatherDashboard-env.eba-ai4q4ugm.us-east-1.elasticbeanstalk.com`
   - **Identity Type**: `Anonymous`

## Installation

### Prerequisites
- Salesforce org with Lightning Experience enabled
- System Administrator or equivalent permissions
- Valid OpenWeatherMap API key

### Deploy to Salesforce

1. **Clone this repository**:
   ```bash
   git clone https://github.com/ratnakar-gumpena/salesforce-weather-integration.git
   cd salesforce-weather-integration
   ```

2. **Deploy using Salesforce CLI**:
   ```bash
   sfdx force:source:deploy -p force-app/main/default
   ```

   Or deploy specific components:
   ```bash
   sfdx force:source:deploy -m "ApexClass:WeatherService,ApexClass:WeatherServiceTest,LightningComponentBundle:accountWeather"
   ```

3. **Complete the Salesforce Setup** (see requirements above)

4. **Add to Account Page Layout**:
   - Go to **Setup → Object Manager → Account → Lightning Record Pages**
   - Edit your Account record page or create a new one
   - Add the **Account Weather** component
   - Save and activate

## Configuration

### API Key Setup
1. Obtain an API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Go to **Setup → Custom Settings → Weather API Settings → Manage**
3. Click **New** (for Organization level)
4. Enter your API key in the **API Key** field
5. Save

### Account Requirements
Accounts must have a **Shipping City** populated for the weather component to work.

## Usage

1. Navigate to any **Account record** with a populated Shipping City
2. The **Weather Information** component will display:
   - Current temperature
   - "Feels like" temperature
   - City name
   - Temperature unit toggle (°C/°F)
3. Use the **refresh button** to get updated weather data
4. Toggle between **Celsius and Fahrenheit** using the switch in the top-right corner

## API Integration

The component integrates with a custom weather API hosted on AWS Elastic Beanstalk:
- **Endpoint**: `/api/weather/{city}?apikey={apikey}`
- **Method**: GET
- **Response**: `{"temperature": 25.5, "feels_like": 27.3}`
- **Units**: Celsius (converted to Fahrenheit in UI when toggled)

## Technical Details

### Architecture
- **Backend**: Apex class handles HTTP callouts to external weather API
- **Frontend**: Lightning Web Component with reactive properties
- **Security**: API credentials managed through Custom Settings
- **Testing**: Comprehensive unit tests with mock HTTP responses

### Browser Support
- All modern browsers supported by Salesforce Lightning Experience
- Responsive design works on desktop and mobile devices

## Troubleshooting

### Common Issues

1. **"Weather API key not configured"**
   - Verify Custom Settings are properly configured
   - Ensure API key is valid and active

2. **"Account does not have a shipping city"**
   - Add a Shipping City to the Account record

3. **API timeout or connection errors**
   - Check Remote Site Settings configuration
   - Verify the weather API endpoint is accessible

### Debug Logs
Enable debug logs for the `WeatherService` class to troubleshoot API integration issues.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit: `git commit -m "Add feature description"`
5. Push: `git push origin feature-name`
6. Create a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

If you have questions or need assistance:
- Create an issue in this repository
- Check Salesforce Trailhead for Lightning Web Component documentation
- Review the Salesforce Developer documentation for Apex HTTP callouts

---

import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getWeatherForAccount from '@salesforce/apex/WeatherService.getWeatherForAccount';

export default class AccountWeather extends LightningElement {
    @api recordId;
    @track weatherData = {};
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track isFahrenheit = false;

    wiredWeatherResult;

    @wire(getWeatherForAccount, { accountId: '$recordId' })
    wiredWeather(result) {
        this.wiredWeatherResult = result;
        const { data, error } = result;

        this.isLoading = false;

        if (data) {
            if (data.success) {
                this.weatherData = data;
                this.hasError = false;
                this.errorMessage = '';
            } else {
                this.hasError = true;
                this.errorMessage = data.errorMessage;
                this.weatherData = {};
            }
        } else if (error) {
            this.hasError = true;
            this.errorMessage = 'Failed to load weather data: ' + error.body.message;
            this.weatherData = {};
        }
    }

    get hasWeatherData() {
        return this.weatherData && this.weatherData.success && !this.isLoading;
    }

    get temperatureDisplay() {
        if (this.hasWeatherData && this.weatherData.temperature !== undefined) {
            const tempCelsius = this.weatherData.temperature;
            if (this.isFahrenheit) {
                const tempFahrenheit = (tempCelsius * 9/5) + 32;
                return Math.round(tempFahrenheit) + '°F';
            } else {
                return Math.round(tempCelsius) + '°C';
            }
        }
        return '';
    }

    get cityDisplay() {
        return this.hasWeatherData ? this.weatherData.city : '';
    }

    get descriptionDisplay() {
        if (this.hasWeatherData && this.weatherData.description) {
            // Convert feels like temperature in description based on toggle
            const feelsLikeMatch = this.weatherData.description.match(/Feels like (\d+)°C/);
            if (feelsLikeMatch) {
                const feelsLikeCelsius = parseInt(feelsLikeMatch[1]);
                if (this.isFahrenheit) {
                    const feelsLikeFahrenheit = (feelsLikeCelsius * 9/5) + 32;
                    return `Feels like ${Math.round(feelsLikeFahrenheit)}°F`;
                } else {
                    return this.weatherData.description;
                }
            }
            return this.weatherData.description;
        }
        return '';
    }

    handleRefresh() {
        this.isLoading = true;
        this.hasError = false;
        this.errorMessage = '';

        refreshApex(this.wiredWeatherResult)
            .then(() => {
                this.showToast('Success', 'Weather data refreshed', 'success');
            })
            .catch(error => {
                this.hasError = true;
                this.errorMessage = 'Failed to refresh weather data';
                this.isLoading = false;
                this.showToast('Error', 'Failed to refresh weather data', 'error');
            });
    }

    handleTemperatureToggle(event) {
        this.isFahrenheit = event.target.checked;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
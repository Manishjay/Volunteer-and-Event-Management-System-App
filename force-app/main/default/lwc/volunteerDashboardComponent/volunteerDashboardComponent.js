import { LightningElement, track, wire } from 'lwc';
// import getVolunteers from '@salesforce/apex/VolunteerDashboardController.getVolunteers';
// import getVolunteerData from '@salesforce/apex/VolunteerDashboardController.getVolunteerData';
// import submitFeedback from '@salesforce/apex/VolunteerDashboardController.submitFeedback';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVolunteers from '@salesforce/apex/VolunteerDashboardController.getVolunteers';
import getVolunteerData from '@salesforce/apex/VolunteerDashboardController.getVolunteerData';

export default class VolunteerDashboardComponent extends LightningElement {
    @track volunteers = [];
    @track selectedVolunteerId;
    @track totalHours;
    @track upcomingEvents = [];
    @track eventOptions = [];
    @track rating = '';
    @track comments = '';

    @wire(getVolunteers)
    wiredVolunteers({ error, data }) {
        if (data) {
            this.volunteers = data.map(volunteer => ({
                label: volunteer.Name,
                value: volunteer.Id
            }));
        } else if (error) {
            console.error('Error fetching volunteers:', error);
        }
    }

    @wire(getVolunteerData, { volunteerId: '$selectedVolunteerId' })
    wiredVolunteerData({ error, data }) {
        if (data) {
            this.totalHours = data.totalHours;
            this.upcomingEvents = data.upcomingEvents;
            this.eventOptions = data.eventOptions;
        } else if (error) {
            console.error('Error fetching volunteer data:', error);
        }
    }

    handleVolunteerChange(event) {
        this.selectedVolunteerId = event.detail.value;
    }

    handleRatingChange(event) {
        this.rating = event.detail.value;
    }

    handleCommentsChange(event) {
        this.comments = event.detail.value;
    }

    handleSubmitFeedback() {
        // Implement feedback submission logic
    }
}
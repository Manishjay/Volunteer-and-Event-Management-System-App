import { LightningElement, track, wire } from 'lwc';
import getVolunteers from '@salesforce/apex/VolunteerDashboardController.getVolunteers';
import getVolunteerData from '@salesforce/apex/VolunteerDashboardController.getVolunteerData';

export default class VolunteerDashboardComponent extends LightningElement {
     @track volunteers = [];
    @track selectedVolunteerId;
    @track totalHours = 0;
    @track upcomingEvents = [];
    @track eventOptions = [];
    @track selectedEventId;
    @track rating = '';
    @track comments = '';

    // Columns for the datatable
    columns = [
        { label: 'Event Name', fieldName: 'eventName', type: 'text' },
        { label: 'Date', fieldName: 'eventDate', type: 'date' },
        { label: 'Location', fieldName: 'location', type: 'text' },
        { label: 'Description', fieldName: 'description', type: 'text' }
    ];

    @wire(getVolunteers)
    wiredVolunteers({ error, data }) {
        if (data) {
            this.volunteers = data.map(volunteer => ({
                label: volunteer.Name,
                value: volunteer.Id
            }));
            console.log('Volunteers:', this.volunteers);
        } else if (error) {
            console.error('Error fetching volunteers:', error);
        }
    }

    @wire(getVolunteerData, { volunteerId: '$selectedVolunteerId' })
    wiredVolunteerData({ error, data }) {
        if (data) {
            console.log('Volunteer Data:', data);
            this.totalHours = data.totalHours || 0;  // Ensure default value of 0
            this.upcomingEvents = data.upcomingEvents || [];  // Ensure default empty array
            this.eventOptions = data.eventOptions || [];  // Ensure default empty array
        } else if (error) {
            console.error('Error fetching volunteer data:', JSON.stringify(error));
            this.totalHours = 0;
            this.upcomingEvents = [];
            this.eventOptions = [];
        }
    }

    handleVolunteerChange(event) {
        this.selectedVolunteerId = event.detail.value;
        console.log('Selected Volunteer ID:', this.selectedVolunteerId);
    }

    handleEventChange(event){
        this.selectedEventId = event.detail.value;
        console.log('Selected Event Id', this.selectedEventId);
    }

    handleRatingChange(event) {
        this.rating = event.detail.value;
        console.log('Rating:', this.rating);
    }

    handleCommentsChange(event) {
        this.comments = event.detail.value;
        console.log('Comments:', this.comments);
    }

    handleSubmitFeedback() {
        console.log('Feedback Submission');   
    }
}
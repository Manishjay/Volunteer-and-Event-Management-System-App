import { LightningElement, track, wire } from 'lwc';
import getAvailableEvents from '@salesforce/apex/EventRegistrationController.getAvailableEvents';
import getRolePicklistValues from '@salesforce/apex/EventRegistrationController.getRolePicklistValues';
import registerVolunteer from '@salesforce/apex/EventRegistrationController.registerVolunteer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EventRegistrationForm extends LightningElement {
    @track selectedEventId; 
    @track selectedRole; 
    @track eventOptions = []; 
    @track roleOptions = []; 
    @track selectedEvent = {}; 

    @wire(getAvailableEvents)
    wiredEvents({ error, data }) {
        if (data) {
            console.log(data);
            this.eventOptions = data.map(event => ({
                label: event.Name, 
                value: event.Id,
                eventDate: event.Event_Date__c,
                location: event.Location__c,
                description: event.Description__c
            }));
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading events',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }

    connectedCallback() {
        this.fetchRolePicklistValues();
    }

    fetchRolePicklistValues() {
        getRolePicklistValues()
            .then(result => {
                this.roleOptions = Object.keys(result).map(key => {
                    return { label: key, value: result[key] };
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading role picklist values',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

   // Handle event change and populate the selectedEvent object
   handleEventChange(event) {
    this.selectedEventId = event.detail.value;
    this.selectedEvent = this.eventOptions.find(evt => evt.value === this.selectedEventId);
}

    handleRoleChange(event) {
        this.selectedRole = event.detail.value;
    }

    handleRegister() {
        console.log('Registration working');
        if (this.selectedEventId && this.selectedRole) {
            registerVolunteer({ eventId: this.selectedEventId, role: this.selectedRole })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'You have been successfully registered!',
                            variant: 'success',
                        }),
                    );
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error registering for event',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Incomplete Information',
                    message: 'Please select an event and a role.',
                    variant: 'warning',
                }),
            );
        }
    }
}
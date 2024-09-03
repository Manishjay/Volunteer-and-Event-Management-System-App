import { LightningElement, wire } from 'lwc';
import getEvents from '@salesforce/apex/EventController.getEvents';
import { loadScript } from 'lightning/platformResourceLoader';
import FULL_CALENDAR_JS from '@salesforce/resourceUrl/fullCalendarJs';



export default class EventCalenderComponent extends LightningElement {
    // fullCalendarJsInitialized = false;
    // events = [];
    // filteredEvents = [];
    // selectedLocation = '';
    // selectedEventType = '';
    // selectedRole = '';
    // locationOptions = [];
    // eventTypeOptions = [];
    // roleOptions = [];

    // @wire(getEvents)
    // wiredEvents({ error, data }) {
    //     if (data) {
    //         this.events = data;
    //         this.filteredEvents = data;
    //         this.extractFilterOptions();
    //         if (this.fullCalendarJsInitialized) {
    //             this.renderCalendar();
    //         }
    //     } else if (error) {
    //         console.error('Error retrieving events:', error);
    //     }
    // }

    // handleLocationChange(event) {
    //     this.selectedLocation = event.detail.value;
    //     this.applyFilters();
    // }

    // handleEventTypeChange(event) {
    //     this.selectedEventType = event.detail.value;
    //     this.applyFilters();
    // }

    // handleRoleChange(event) {
    //     this.selectedRole = event.detail.value;
    //     this.applyFilters();
    // }

    fullCalendarJsInitialised = false;

    renderedCallback() {

        // Performs this operation only on first render
        if (this.fullCalendarJsInitialised) {
          return;
        }
        this.fullCalendarJsInitialised = true;

        // Load the FullCalendar library
        loadScript(this, FULL_CALENDAR_JS)
            .then(() => {
                this.initializeCalendar();
                // this.calendarInitialized = true; // Mark the calendar as initialized
            })
            .catch(error => {
                console.error('Error loading FullCalendar:', error);
            });
    }

    initializeCalendar() {
        // Ensure the calendar element is correctly selected
        const calendarEl = this.template.querySelector('canvas.fullcalendarjs');

        if (!calendarEl) {
            console.error('Calendar element not found');
            return;
        }

        // Initialize FullCalendar
        const calendar = new FullCalendar.Calendar(calendarEl, {
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay'
            },
            initialDate: new Date(),
            navLinks: true,
            editable: true,
            selectable: true,
            events: this.events, // Use events from your Salesforce data
            eventClick: (info) => {
                const selectedEvent = new CustomEvent('eventclicked', {
                    detail: info.event.id
                });
                this.dispatchEvent(selectedEvent);
            }
        });

        // Render the calendar
        calendar.render();
    }
    
}

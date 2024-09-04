import { LightningElement, wire, track } from 'lwc';
import getEvents from '@salesforce/apex/EventController.getEvents';
import { loadScript } from 'lightning/platformResourceLoader';
import FULL_CALENDAR_JS from '@salesforce/resourceUrl/fullCalendarJs';

export default class EventCalenderComponent extends LightningElement {
    fullCalendarJsInitialized = false;
    events = [];
    filteredEvents = [];
    selectedLocation = '';
    selectedRole = '';
    locationOptions = [];
    roleOptions = [];

    @wire(getEvents)
    wiredEvents({ error, data }) {
        if (data) {
            console.log(data);
            this.events = data.map(eventRecord => ({
                location: eventRecord.location,
                roles: eventRecord.roles
            }));

            this.filteredEvents = this.events;
            this.extractFilterOptions();
            if (this.fullCalendarJsInitialized) {
                this.initializeCalendar();
            }
        } else if (error) {
            console.error('Error retrieving events:', error);
        }
    }

    extractFilterOptions() {
        // Extract unique locations from the events
        this.locationOptions = [...new Set(this.events.map(event => event.location))]
            .map(location => ({
                label: location,
                value: location
            }));

        // Extract unique roles from the events
        const allRoles = new Set();
        this.events.forEach(event => {
            event.roles.forEach(role => {
                allRoles.add(role);
            });
        });
        this.roleOptions = [...allRoles].map(role => ({
            label: role,
            value: role
        }));
    }

    handleLocationChange(event) {
        this.selectedLocation = event.detail.value;
        this.applyFilters();
    }

    handleRoleChange(event) {
        this.selectedRole = event.detail.value;
        this.applyFilters();
    }

    applyFilters() {
        this.filteredEvents = this.events.filter(event => {
            const locationMatch = !this.selectedLocation;
            const roleMatch = !this.selectedRole;
            return locationMatch && roleMatch;
        });

        this.initializeCalendar(); // Re-initialize the calendar with the filtered events
    }

    renderedCallback() {
        if (this.fullCalendarJsInitialized) {
            return;
        }
        this.fullCalendarJsInitialized = true;

        loadScript(this, FULL_CALENDAR_JS)
            .then(() => {
                this.initializeCalendar();
            })
            .catch(error => {
                console.error('Error loading FullCalendar:', error);
            });
    }

    initializeCalendar() {
        const calendarEl = this.template.querySelector('.calendar');

        if (!calendarEl) {
            console.error('Calendar element not found');
            return;
        }

        calendarEl.render();

        // const calendar = new FullCalendar.Calendar(calendarEl, {
        //     headerToolbar: {
        //         left: 'prev,next today',
        //         center: 'title',
        //         right: 'dayGridMonth,timeGridWeek,timeGridDay'
        //     },
        //     initialDate: new Date(),
        //     navLinks: true,
        //     editable: true,
        //     selectable: true,
        //     events: this.filteredEvents.map(event => ({
        //         id: event.id,
        //         title: event.title,
        //         start: event.date
        //     })),
        //     eventClick: (info) => {
        //         const selectedEvent = new CustomEvent('eventclicked', {
        //             detail: info.event.id
        //         });
        //         this.dispatchEvent(selectedEvent);
        //     }
        // });

        calendar.render();
    }      
}

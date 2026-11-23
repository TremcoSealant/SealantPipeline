import { LightningElement, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { getSessionContext } from 'commerce/contextApi';
import getMyProjects from '@salesforce/apex/Tremco_MyProjectsController.getMyProjects';

export default class TremcoMyProjects extends LightningElement {
    @track projectRows = [];
    @track loading = false;
    @track errorMessage = '';

    mobileView = false;
    effectiveAccountId;

    columns = [
        {
            label: 'Project Name',
            fieldName: 'projectName',
            hideSort: false,
            filterable: false,
            searchable: true,
            searchableLabel: 'Project Name'
        },
        {
            label: 'Project City',
            fieldName: 'projectCity',
            hideSort: false,
            filterable: false,
            searchable: true,
            searchableLabel: 'Project City'
        },
        {
            label: 'Project State',
            fieldName: 'projectState',
            hideSort: false,
            filterable: false,
            searchable: true,
            searchableLabel: 'Project State'
        },
        {
            label: 'Target Start Date',
            fieldName: 'targetStartDate',
            hideSort: false,
            filterable: false,
            searchable: false
        }
    ];

    connectedCallback() {
        this.mobileView = FORM_FACTOR === 'Small' || FORM_FACTOR === 'Medium';
        this.initialize();
    }

    async initialize() {
        this.loading = true;
        this.errorMessage = '';

        try {
            const context = await getSessionContext();
            this.effectiveAccountId = context ? context.effectiveAccountId : null;
            const records = await getMyProjects({ accountId: this.effectiveAccountId });
            this.projectRows = (records || []).map((record) => {
                const row = {
                    id: record.projectId,
                    projectName: record.projectName || '',
                    projectCity: record.projectCity || '',
                    projectState: record.projectState || '',
                    targetStartDate: record.targetStartDate || ''
                };
                row.SearchableValues = this.populateSearchableValue(row);
                return row;
            });
        } catch (error) {
            this.projectRows = [];
            this.errorMessage = 'Unable to load projects. Please refresh and try again.';
            console.error('tremcoMyProjects: failed to load projects', error);
        } finally {
            this.loading = false;
        }
    }

    get hasProjects() {
        return this.projectRows.length > 0;
    }

    get showEmptyState() {
        return !this.errorMessage && !this.hasProjects;
    }

    // Builds the SearchableValues array rocketDataTable uses to match the search term.
    populateSearchableValue(row) {
        const searchableValues = [];
        this.columns.forEach((col) => {
            if (col.searchable) {
                searchableValues.push(row[col.fieldName]);
            }
        });
        return searchableValues;
    }
}
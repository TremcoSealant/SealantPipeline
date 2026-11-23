import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getNavigationMenu } from 'experience/navigationMenuApi';
import { NavigationMixin } from "lightning/navigation";
import { getSessionContext } from 'commerce/contextApi';
import isGuestUser from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';
import getContactData from '@salesforce/apex/Tremco_ContactController.getContactData';

export default class RocketProfileMenu extends NavigationMixin(LightningElement) {
    //guest style properties
    @api guestLinkText;
    @api guestLinkColor;
    @api guestLinkHoverColor;
    @api guestLinkOrientation;
    @api guestTextStyleBold;
    @api guestTextStyleItalic;
    @api guestTextStyleUnderline;
    @api guestTextStyleStrikethrough;

    //authenticated user properties
    @api authUserMenuStyle;
    @api authMenuBackgroundColor;
    @api authTextColor;
    @api authHoverColor;
    @api authIconStyle;
    @api authIncludeCompanyName;
    @api authTextOrientation;
    @api authDefaultMenu;
    @api authLogOut;
    
    @track menuItems = [];
    @track isLoaded = false;
    @track error;

    //SSN-290: current user's Contact permission flags used to hide privileged menu items
    @track isAccountAdmin = false;
    @track isApprover = false;

    //SSN-290: labels of menu items that are gated by Contact permissions
    USER_MANAGEMENT_LABEL = 'user management';
    APPROVAL_DASHBOARD_LABEL = 'approval dashboard';

    publishStatus;
    authDefaultMenuDeveloperName;
    userName;
    accountName;

    //OOTB profile menu skips these navigation types
    menuItemsToSkip = ["DataSourceDriven", "Event", "GlobalAction", "MenuLabel", "NavigationalTopic"];

    connectedCallback() {
        this.init();
        this.initCSSVariables();
        this.loadContactPermissions();
        this.authDefaultMenuDeveloperName = this.authDefaultMenu ? this.authDefaultMenu.replaceAll(' ','_') : null;
        document.addEventListener('click', this.close.bind(this));
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.close.bind(this));
    }

    //get session context to set logged in user name and account name to display
    init() {
        getSessionContext()
        .then((result) => {
            this.userName = result.userName;
            this.accountName = result.effectiveAccountName;
        }).catch((e) => {
            console.log(e);
        })
    }

    //SSN-290: load the current user's Contact flags so privileged menu items can be hidden.
    //Fails closed (hides the items) if the permissions cannot be determined.
    loadContactPermissions() {
        if (this.isGuest) {
            return;
        }
        getContactData()
        .then((contact) => {
            this.isAccountAdmin = contact && contact.Account_Admin__c === true;
            this.isApprover = contact && contact.Approver__c === true;
        }).catch((e) => {
            this.isAccountAdmin = false;
            this.isApprover = false;
            console.error('rocketProfileMenu: unable to load contact permissions', e);
        })
    }

    //SSN-290/SSN-321: hide admin-only and approver-only menu options based on Contact permissions.
    get visibleMenuItems() {
        return (this.menuItems || []).filter((item) => {
            const label = (item && item.label ? item.label : '').trim().toLowerCase();
            if (!this.isAccountAdmin && label === this.USER_MANAGEMENT_LABEL) {
                return false;
            }
            if (!this.isApprover && !this.isAccountAdmin && label === this.APPROVAL_DASHBOARD_LABEL) {
                return false;
            }
            return true;
        });
    }

    //sets the authorable properties from experience builder to be used in CSS file as named variables
    initCSSVariables() {
        var css = this.template.host.style;
        css.setProperty('--guestLinkColor', this.guestLinkColor);
        css.setProperty('--guestLinkHoverColor', this.guestLinkHoverColor);
        css.setProperty('--guestTextDecoration', this.guestTextDecoration);
        css.setProperty('--guestTextStyleBold', this.guestTextStyleBold ? 'bold' : 'normal');
        css.setProperty('--guestTextStyleItalic', this.guestTextStyleItalic ? 'italic' : 'normal');
        css.setProperty('--guestLinkOrientation', this.guestLinkOrientation === 'Left of Icon' ? 'row' : 'row-reverse');
        css.setProperty('--authTextOrientation', this.authTextOrientation === 'Left of Icon' ? 'row' : 'row-reverse');
        css.setProperty('--authMenuBackgroundColor', this.authMenuBackgroundColor);
        css.setProperty('--authTextColor', this.authTextColor);
        css.setProperty('--authHoverColor', this.authHoverColor);
    }

    /**
     * Using getNavigationMenu from experience/navigationMenuApi, query for the NavigationMenuItems using the
     * menu name and published state.
     * https://developer.salesforce.com/docs/atlas.en-us.242.0.chatterapi.meta/chatterapi/connect_resources_navigation_menu_items.htm
    */

    @wire(getNavigationMenu, {
        publishStatus: '$publishStatus',
        navigationLinkSetDeveloperName: '$authDefaultMenuDeveloperName',
        menuItemsToSkip: '$menuItemsToSkip'
    })
    wiredMenuItems({error, data}) {
        if (data && !this.isLoaded) {
            this.menuItems =  JSON.parse(JSON.stringify(data.menuItems));
            this.error = undefined;
            this.isLoaded = true;
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.isLoaded = true;
            console.error(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }

    /**
     * Using the CurrentPageReference, check if the app is 'commeditor'.
     * 
     * If the app is 'commeditor', then the page will use 'Draft' NavigationMenuItems. 
     * Otherwise, it will use the 'Live' schema.
    */
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app = currentPageReference && currentPageReference.state && currentPageReference.state.app;
        if (app === 'commeditor') {
            this.publishStatus = 'Draft';
        } else {
            this.publishStatus = 'Live';
        }
    }

    //Logic for guest text styles
    get guestTextDecoration() {
        if (this.guestTextStyleStrikethrough && this.guestTextStyleUnderline) {
            return 'line-through underline';
        } else if (this.guestTextStyleStrikethrough && !this.guestTextStyleUnderline) {
            return 'line-through';
        } else if (!this.guestTextStyleStrikethrough && this.guestTextStyleUnderline) {
            return 'underline';
        } else {
            return 'none';
        }
    }

    //used to display guest log in button or authenticated user menu dropdown
    get isGuest() {
        return isGuestUser;
    }

    //used to show/hide the user name next to icon based on menu style selection
    get showUserName() {
        return this.authUserMenuStyle === 'Icon And Name';
    }

    //checkbox to Include Company Name will only work if Icon and Name is selected from the User Menu Style dropdown
    get showCompanyName() {
        return this.showUserName && this.authIncludeCompanyName;
    }

    //used to change Icon when Company Logo is selected
    get companyLogoIcon() {
        return this.authIconStyle === 'Company Logo';
    }

    //opens and closes dropdown menu on click
    toggleMenu(e) {
        e.stopPropagation();
        e.currentTarget.parentElement.classList.toggle('slds-is-open');
    }

    handleLogin() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
              url: `${basePath}/login`
            },
        }, true // Set replace to true to close the previous modal automatically-SSN-9
        ); 
    }

    handleLogout() {
        let logOuturl = `${basePath}/vforcesite/secur/logout.jsp`;
        window.location.href = logOuturl;
    }

    //on click outside of the dropdown will close the menu
    close() { 
        this.template.querySelector('div.profile-menu__trigger').classList.remove('slds-is-open');
    }
}
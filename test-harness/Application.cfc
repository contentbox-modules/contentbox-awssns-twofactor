/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component{

	// UPDATE THE NAME OF THE MODULE IN TESTING BELOW
	request.MODULE_NAME = "contentbox-awssns-twofactor";

	// Application properties
	this.name              = "#request.MODULE_NAME# Tester";
	this.sessionManagement 	= true;
	this.sessionTimeout 	= createTimeSpan( 0, 1, 0, 0 );
    this.setClientCookies 	= true;
	this.setDomainCookies 	= true;

    /**************************************
	LUCEE Specific Settings
	**************************************/
	// buffer the output of a tag/function body to output in case of a exception
	this.bufferOutput 					= true;
	// Activate Gzip Compression
	this.compression 					= false;
	// Turn on/off white space managemetn
	this.whiteSpaceManagement 			= "smart";
	// Turn on/off remote cfc content whitespace
	this.suppressRemoteComponentContent = false;

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH       = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING         = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE 	    = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY 		    = "";

	//applicationstop();abort;

    // Mappings
	this.mappings[ "/root" ] 				= COLDBOX_APP_ROOT_PATH;
	this.mappings[ "/coldbox" ] 			= COLDBOX_APP_ROOT_PATH & "coldbox";
	this.mappings[ "/contentbox" ] 			= COLDBOX_APP_ROOT_PATH & "modules/contentbox";
	this.mappings[ "/cborm" ] 	 			= this.mappings[ "/contentbox" ] & "/modules/contentbox-deps/modules/cborm";

	// Map back to its root
	moduleRootPath 	= REReplaceNoCase( this.mappings[ "/root" ], "#request.MODULE_NAME#(\\|/)test-harness(\\|/)", "" );
	modulePath 		= REReplaceNoCase( this.mappings[ "/root" ], "test-harness(\\|/)", "" );

	// Module Root + Path Mappings
	this.mappings[ "/moduleroot" ] = moduleRootPath;
	this.mappings[ "/#request.MODULE_NAME#" ] = modulePath;

	// THE CONTENTBOX DATASOURCE NAME
	this.datasource = "contentbox";
	// ORM SETTINGS
	this.ormEnabled = true;
	this.ormSettings = {

		// ENTITY LOCATIONS, ADD MORE LOCATIONS AS YOU SEE FIT
		// IF YOUR MODULE USES ENTITIES, THEN MAKE SURE YOU ADD IT HERE
		cfclocation=[ "modules", "modules_app" ],

		// THE DIALECT OF YOUR DATABASE OR LET HIBERNATE FIGURE IT OUT, UP TO YOU TO CONFIGURE
		//dialect = "MySQLwithInnoDB",

		// ORM SESSION MANAGEMENT SETTINGS, DO NOT CHANGE
		logSQL 				= true,
		flushAtRequestEnd 	= false,
		autoManageSession	= false,

		// ORM EVENTS MUST BE TURNED ON FOR CONTENTBOX TO WORK
		eventHandling 		= true,
		eventHandler		= "cborm.models.EventHandler",

		// THIS IS ADDED SO OTHER CFML ENGINES CAN WORK WITH CONTENTBOX, USE FALSE FOR DEBUGGING
		skipCFCWithError	= true
	};

	// application start
	public boolean function onApplicationStart(){
		// Set a high timeout for any orm updates
		setting requestTimeout="300";
		application.cbBootstrap = new coldbox.system.Bootstrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );
		application.cbBootstrap.loadColdbox();
		return true;
	}

	// request start
	public boolean function onRequestStart(String targetPage){

		// Process ColdBox Request
		application.cbBootstrap.onRequestStart( arguments.targetPage );

		return true;
	}

	public void function onSessionStart(){
		application.cbBootStrap.onSessionStart();
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection=arguments );
	}

	public boolean function onMissingTemplate( template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection=arguments );
	}

}
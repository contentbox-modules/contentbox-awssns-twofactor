/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component{

	// UPDATE THE NAME OF THE MODULE IN TESTING BELOW
	request.MODULE_NAME = "contentbox-awssns-twofactor";

	// APPLICATION CFC PROPERTIES
	this.name 				= "ContentBox Testing Suite";
	this.sessionManagement 	= true;
	this.sessionTimeout 	= createTimeSpan( 0, 0, 15, 0 );
	this.applicationTimeout = createTimeSpan( 0, 0, 15, 0 );
	this.setClientCookies 	= true;

	// Create testing mapping
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );

	// The application root
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );

	this.mappings[ "/root" ]   		= rootPath;
	this.mappings[ "/cbapp" ]   	= rootPath;
	this.mappings[ "/coldbox" ] 	= rootPath & "coldbox" ;
	this.mappings[ "/testbox" ] 	= rootPath & "testbox" ;
	this.mappings[ "/contentbox" ] 	= rootPath & "modules/contentbox";
	this.mappings[ "/cborm" ] 	 	= this.mappings[ "/contentbox" ] & "/modules/contentbox-deps/modules/cborm";


	this.ormEnabled = true;
	this.datasource = "contentbox";
	this.ormSettings = {
		cfclocation			= [ rootPath & "/modules", rootPath & "/modules_app" ],
		logSQL 				= true,
		flushAtRequestEnd 	= false,
		autoManageSession	= false,
		eventHandling 		= true,
		eventHandler		= "cborm.models.EventHandler",
		skipCFCWithError	= true,
		secondarycacheenabled = false
	};

	public boolean function onRequestStart(String targetPage){

		// LOCATION MAPPINGS
		application.moduleRootPath 	= REReplaceNoCase( rootPath, "#request.MODULE_NAME#(\\|/)test-harness(\\|/)", "" );
		application.modulePath 		= application.moduleRootPath & request.MODULE_NAME;
		application.MODULE_NAME 	= request.MODULE_NAME;

		// Set a high timeout for long running tests
		setting requestTimeout="9999";

		// ORM Reload for fresh results
		if( structKeyExists( url, "fwreinit" ) ){
			if( structKeyExists( server, "lucee" ) ){
				pagePoolClear();
			}
			ormReload();
		}

		return true;
	}

	public void function onRequestEnd() {
        structDelete( application, "cbController" );
        structDelete( application, "wirebox" );
	}

}
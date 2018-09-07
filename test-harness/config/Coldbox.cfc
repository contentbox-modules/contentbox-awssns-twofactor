/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* ColdBox Configuration
*/
component{

	// Configure Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 					= "ContentBox Modular CMS",

			//Development Settings
			reinitPassword				= "@fwPassword@",
			handlersIndexAutoReload 	= false,

			//Implicit Events
			defaultEvent				= "Main.index",
			requestStartHandler			= "",
			requestEndHandler			= "",
			applicationStartHandler 	= "",
			applicationEndHandler		= "",
			sessionStartHandler 		= "",
			sessionEndHandler			= "",
			missingTemplateHandler		= "",

			//Extension Points
			applicationHelper 			= "",
			viewsHelper					= "",
			modulesExternalLocation		= [],
			viewsExternalLocation		= "",
			layoutsExternalLocation 	= "",
			handlersExternalLocation  	= "",
			requestContextDecorator 	= "",
			controllerDecorator			= "",

			//Error/Exception Handling
			exceptionHandler			= "",
			onInvalidEvent				= "",
			customErrorTemplate 	= "/coldbox/system/includes/BugReport.cfm",

			//Application Aspects
			handlerCaching 				= false,
			eventCaching				= false,
			viewCaching 				= false
		};

		// custom settings
		settings = {

		};

		// environment settings, create a detectEnvironment() method to detect it yourself.
		// create a function with the name of the environment so it can be executed if that environment is detected
		// the value of the environment is a list of regex patterns to match the cgi.http_host.
		environments = {
			development = "localhost,dev,127\.0"
		};

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				files={class="coldbox.system.logging.appenders.RollingFileAppender",
					properties = {
						filename = "tester", filePath="/#appMapping#/logs"
					}
				}
			},
			// Root Logger
			root = { levelmax="DEBUG", appenders="*" },
			// Implicit Level Categories
			info = [ "coldbox.system" ]
		};

		// Layout Settings
		layoutSettings = {
			defaultLayout = "",
			defaultView   = ""
		};

		// Interceptor Settings
		interceptorSettings = {
			customInterceptionPoints = ""
		};

		// ORM Module Configuration
		orm = {
			// Enable Injection
			injection = {
				enabled = true
			}
		};

		//Register interceptors as an array, we need order
		interceptors = [
			//SES
			{ class="coldbox.system.interceptors.SES" }
		];

		// ContentBox relies on the Cache Storage for tracking sessions, which delegates to a Cache provider
		storages = {
		    // Cache Storage Settings
		    cacheStorage = {
		        cachename   = "sessions",
		        timeout     = 60 // The default timeout of the session bucket, defaults to 60
		    }
		};

		// ContentBox Runtime Overrides
		"contentbox" = {
			// Runtime Settings Override by site slug
		  	"settings" = {
		  		// Default site
		  		"default" = {
		  			//"cb_media_directoryRoot" 	= "/docker/mount"
		  		}
		  	}
		};

		// Mail settings for writing to log files instead of sending mail on dev.
		mailsettings.protocol = {
			class = "cbmailservices.models.protocols.FileProtocol",
			properties = {
				filePath = "/logs"
			}
		};

		moduleSettings = {
			snssdk = {
				// Your amazon access key
				accessKey = getSystemSetting( "AWS_ACCESS_KEY", "" ),
				// Your amazon secret key
				secretKey = getSystemSetting( "AWS_ACCESS_SECRET", "" )
			}
		};

	}

	/**
	 * Load Mappings per request
	 */
	function preProcess( event, interceptData, rc, prc ){
		loadModuleMappings();
	}

	/**
	 * Load the Module you are testing
	 */
	function afterAspectsLoad( event, interceptData, rc, prc ){
		// Load Dynamic Mappings so ORM doesn't caput due to ACF Bugs
		loadModuleMappings();
		// activate target module.
		controller.getModuleService()
			.registerAndActivateModule(
				moduleName 		= application.MODULE_NAME,
				invocationPath 	= "moduleroot"
			);
	}

	/**
	 * Load all needed mappings here.
	 */
	private function loadModuleMappings(){
		controller.getUtil()
			.addMapping( "/moduleroot", application.moduleRootPath );
		controller.getUtil()
			.addMapping( "/#application.MODULE_NAME#", application.modulePath );
	}

}

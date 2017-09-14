/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* Provides AWS SNS two factor authentication. This provider leverages the `template` cache
* to store unique tokens.
*/
component 
	extends="contentbox.models.security.twofactor.BaseTwoFactorProvider"
	implements="contentbox.models.security.twofactor.ITwoFactorProvider"
	singleton
	threadsafe{

	// DI
	property name="AmazonSNS"		inject="AmazonSNS@snssdk";
	property name="cache"			inject="cachebox:template";

	// Static Variables
	variables.ALLOW_TRUSTED_DEVICE 	= true;
	variables.TOKEN_TIMEOUT 		= 5;

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	* Get the internal name of the provider
	*/
	function getName(){
		return "awssns";
	}
	
	/**
	* Get the display name of the provider
	*/
	function getDisplayName(){
		return "AWS SNS Message";
	};

	/**
	* Get the display help for the provider.  Used in the UI setup screens for the author
	*/
	function getAuthorSetupHelp(){
		return "Make sure you have a valid phone number setup in your author details.  We will use this phone number
			to send you verification tokens to increase your account's security.";
	}

	/**
	* Get the display help for the provider.  Used in the UI verification screen.
	*/
	function getVerificationHelp(){
		return "Please enter the verification code that was sent to your account phone number.";
	}

	/**
	* Get the author options form. This will be sent for saving. You can listen to save operations by 
	* listening to the event 'cbadmin_onAuthorTwoFactorSaveOptions'
	*/
	function getAuthorOptions(){
		return "";
	}

	/**
	 * If true, then ContentBox will set a tracking cookie for the authentication provider user browser.
	 * If the user, logs in and the device is within the trusted timespan, then no two-factor authentication validation will occur.
	 */
	boolean function allowTrustedDevice(){
		return variables.ALLOW_TRUSTED_DEVICE;
	}

	/**
	 * This function will store a validation token in hash for the user to validate on
	 *
	 * @author The author to create the token for.
	 */
	string function generateValidationToken( required author ){
		// Store Security Token For X minutes
		var token = left( 
			hash( arguments.author.getEmail() & arguments.author.getAuthorID() & now() ),
			6
		);
		// Cache the code for 5 minutes
		cache.set(
			"awssns-twofactor-token-#token#",
			arguments.author.getAuthorID(),
			TOKEN_TIMEOUT,
			TOKEN_TIMEOUT
		);
		return token;
	}

	/**
	 * Send a challenge via the 2 factor auth implementation.
	 * The return must be a struct with an error boolean bit and a messages string
	 * 
	 * @author The author to challenge
	 * 
	 * @return struct:{ error:boolean, messages=string }
	 */
	struct function sendChallenge( required author ){
		var results 	= { "error" = false, "messages" = "" };
		var settings 	= getAllSettings();
		
		try{
			var token = generateValidationToken( arguments.author );

			// Build body tokens
			var bodyTokens = {
				name 			= arguments.author.getName(),
				email 			= arguments.author.getEmail(),
				phone			= arguments.author.getPreference( "mobilePhone", "" ),
				username 		= arguments.author.getUsername(),
				ip 				= settingService.getRealIP(),
				tokenTimeout 	= TOKEN_TIMEOUT,
				token 			= token,
				siteName 		= settings.cb_site_name
			};

			var snsMessage = "Your Two Factor Authentication Code from #settings.cb_site_name# is: #token#";

//			snsMessage = renderer.get()
//					.renderLayout(
//						layout 		= "/contentbox/email_templates/layouts/email",
//						view 		= "sms/verification",
//						args 		= { viewModule 	= "contentbox-email-twofactor" }
//					)
			var phoneNumber = arguments.author.getPreference( "mobilePhone", "" );
			/*if( len( phoneNumber ) < 1 ){
				results.error 		= true;
				results.messages	= "Please add a `mobilePhone` preference to your author account. US Numbers should be 11 digit numbers starting with 1 for international. Formatting is allowed.";
				return results;
			}*/
			
			// send it out
			try {
				amazonSNS.publishToPhone( '+#getStrippedPhone( phoneNumber )#', snsMessage );
				results.messages = "Validation code sent!";
			} catch ( any e ){
				results.error 		= true;
				results.messages 	= "#e.message# #e.detail#";
				return results;
			}	
			// Send it to the user
		} catch( Any e ){
			results.error 		= true;
			results.messages 	= "Error Sending AWS SNS Challenge: #e.message# #e.detail#"; 
			// Log this.
			log.error( "Error Sending AWS SNS Challenge: #e.message# #e.detail#", e );
		}
		
		return results;
	}

	/**
	 * Verify the challenge 
	 * 
	 * @code The verification code
	 * @author The author to verify challenge
	 *
	 * @return struct:{ error:boolean, messages:string }
	 */
	struct function verifyChallenge( required string code, required author ){
		var results = { "error" : false, "messages" = "" };
		var authorID = cache.get( "awssns-twofactor-token-#arguments.code#" );

		// Verify it exists and is valid
		if( !isNull( authorID ) AND arguments.author.getAuthorID() eq authorID ){
			results.messages = "Code validated!";
		} else {
			results.error = true;
			results.messages = "Invalid code. Please try again!";
		}

		return results;
	}

	/**
	 * This method is called once a two factor challenge is accepted and valid. 
	 * Meaning the user has completed the validation and will be logged in to ContentBox now.
	 *
	 * @code The verification code
	 * @author The author to verify challenge
	 *
	 */
	function finalize( required string code, required author ){
		// clear out the codes
		cache.clear( "awssns-twofactor-token-#arguments.code#" );
	}
	
	private function getStrippedPhone( phoneNumber ){
		var phone = arguments.phoneNumber;
		phone = ReReplaceNoCase( phone,"[^0-9]","","all");
		return phone;
	}

}
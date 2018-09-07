component extends="coldbox.system.testing.BaseTestCase" appMapping="/root"{

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		reset();
		super.beforeAll();
	}

	function afterAll(){
		super.afterAll();
	}

/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "ContentBox AWS SNS Two Factor", function(){

			beforeEach(function( currentSpec ){
				setup();
			});

			it( "can load the AWS Provider", function(){
				var provider = getInstance( "AwsSNSTwoFactorProvider@contentbox-awssns-twofactor" );
				expect(	provider ).toBeComponent();
			});



		});

	}

}
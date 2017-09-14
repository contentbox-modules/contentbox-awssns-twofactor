<cfoutput>
    <cfset ETH = getModel( "EmailTemplateHelper@cb" )>
    #ETH.text( "Your Two Factor Authentication Code from @siteName@ is: #token#" )#
</cfoutput>

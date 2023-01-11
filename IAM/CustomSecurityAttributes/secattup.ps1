# Form arguments
param(
    [string]$File,
    [string]$attributeName,
    [string]$attributeValue,
    [string]$attributeSet
)

# Tokens to retrieve access (hardcoded)
$clientId = "Application Id Here"
$clientSecret = "Client Secret Here"
$tenantId = "Tenant Id Here"

# Check if all parameters are passed
if(!$File -or !$attributeName -or !$attributeValue -or !$attributeSet) {
    Write-Error "Please provide all arguments
    -File
    -attributeName
    -attributeValue
    -attributeSet"
    return
}

# Constants
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$tokenFile = "$scriptDir\token.json"
$tokenJson = Get-Content -Raw -Path $tokenFile | ConvertFrom-Json
$expires_on = $tokenJson.expires_on
$currentTime = Get-Date

# Access request formatting
$Authbody = @{
    client_id = $clientId
    client_secret = $clientSecret
    grant_type = "client_credentials"
    resource = "https://graph.microsoft.com"
}

# Check if token is expired, get a new one if it is.
if ($expires_on -lt $currentTime) {

    #token is expired
    Write-Host "Token expired, getting a new token."

    # Make request
    $AuthResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $Authbody

    # Store token from request
    $accessToken = $AuthResponse.access_token
    $expires_on = $AuthResponse.expires_on
    
    #overwrite the json file with new token and expiration time
    $token = @{
        "access_token" = $accessToken
        "expires_on" = $expires_on
    }
    $token | ConvertTo-Json | Out-File -FilePath $tokenFile
}
else{
    #token is still valid
    Write-Host "Token is valid, no need to get a new one."
    $accessToken = $tokenJson.access_token
}

# Output how long until it expires
# $expires_on = $([datetime]::new(1970,1,1,0,0,0,0).addseconds($expires_on))
# write-host "The token expires at this time: $expires_on"
# $timeLeft = New-TimeSpan -Start $currentTime -End $expires_on
# Write-Host "Time Left:"
# Write-Host "$($timeLeft.Hours) Hours"
# Write-Host "$($timeLeft.Minutes) Minutes"

$endpoint = "https://graph.microsoft.com/beta/users/"
$json = @"
{
    "customSecurityAttributes":
    {
        "$attributeSet":
        {
            "@odata.type":"#Microsoft.DirectoryServices.CustomSecurityAttributeValue",
            "$attributeName":"$attributeValue"
        }
    }
}
"@

# Make the updates
foreach ($user in Get-Content $File) {
    $uri = "$endpoint/$user"
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    Invoke-RestMethod -Method Patch -Uri $uri -Body $json -ContentType "application/json" -Headers $headers
}
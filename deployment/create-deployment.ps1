$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Token $env:MAPPED_GITHUB_TOKEN")
$headers.Add("Accept", "application/json")

$body = @{
    ref         = $Env:BUILD_SOURCEBRANCHNAME
    description = "Deploying branch to development"
    environment = "development"
    required_contexts = @()
}

$json = $body | ConvertTo-Json

Write-Output "$json" 

Write-Output "Token $env:MAPPED_GITHUB_TOKEN"

$response = Invoke-RestMethod "https://api.github.com/repos/octodemo/ReadingTimeDemo/deployments" -Headers $headers -Method Post -Body $json -ContentType 'application/json'

Write-Host "$("##vso[task.setvariable variable=DeployId]")$($response.id)"

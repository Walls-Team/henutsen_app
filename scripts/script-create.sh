#!/bin/bash

echo Script pagina de henutsen.co

ProjectName="henutsen-web"
ProfileName="$ProjectName-cdn"
ResourceGroupName="$ProjectName-rg"
EndpointName="$ProjectName-endpoint"
#SourcePath="$GITHUB_WORKSPACE/web/co"
AccountName="henutsenstorageaccountco"
urlAccount="https://$AccountName.blob.core.windows.net/\$web"
Location="eastus"
ZoneDns="henutsen.co"
ResourceGroupNameDns="DnsRg"
NameResourceCName="www"
path="/index.html" 

echo login

az login -u jmolina@audisoft.com -p 9o+PA1cXh*

echo ZoneDns-----

az network dns zone create -g $ResourceGroupNameDns -n $ZoneDns

echo CName-----

az network dns record-set cname create -g $ResourceGroupNameDns -z $ZoneDns -n $NameResourceCName  --ttl 30

az network dns record-set cname set-record -g $ResourceGroupNameDns -z $ZoneDns -n $NameResourceCName -c henutsen-web-endpoint.azureedge.net 

echo create accountStorage----

az storage account create -n $AccountName -g $ResourceGroupName -l $Location --sku Standard_LRS  --kind=StorageV2 --access-tier=Hot

echo createBlob----

az storage blob service-properties update --account-name $AccountName --static-website --404-document error-document-name --index-document index.html

echo uploadFile----

az storage blob upload-batch -s $1 -d $urlAccount 

echo getUrl----

ur=$(az storage account show -n $AccountName -g $ResourceGroupName --query "primaryEndpoints.web" --output tsv) 
url=$(echo $ur | cut -c 9- | rev | cut -c2- | rev) 
 
echo "$url"

echo createCdnProfile ----

az cdn profile create -g $ResourceGroupName -n $ProfileName --sku Standard_Microsoft -l $Location

echo createCdnEndpoint ----

az cdn endpoint create -g $ResourceGroupName -n $EndpointName --profile-name $ProfileName --origin $url  --origin-host-header $url

echo createCustomDomain-----
sleep 2s

az cdn custom-domain create -g $ResourceGroupName --profile-name $ProfileName --endpoint-name $EndpointName -n www-domain --hostname www.henutsen.co

echo EnableHttps

az cdn custom-domain enable-https -g $ResourceGroupName --profile-name $ProfileName --endpoint-name $EndpointName -n www-domain

#echo Redirecthttps----

#az cdn endpoint rule add -g henutsen-web-rg -n henutsen-web-endpoint --profile-name henutsen-web-cdn --order 1 --rule-name "Http to Https" --match-variable #RequestScheme --operator Equal --match-values HTTPS --action-name "UrlRedirect" --redirect-protocol Https --redirect-type Moved


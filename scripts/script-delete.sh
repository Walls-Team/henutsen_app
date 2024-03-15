#!/bin/bash

echo Script eliminar pagina de henutsen.co

ProjectName="henutsen-web"
ProfileName="$ProjectName-cdn"
ResourceGroupName="$ProjectName-rg"
AccountName="henutsenstorageaccountco"
ZoneDns="henutsen.co"
ResourceGroupNameDns="DnsRg"


echo login

az login -u jmolina@audisoft.com -p 9o+PA1cXh*

echo deleteZoneDns-----

az network dns zone delete -g $ResourceGroupNameDns -n $ZoneDns -y

echo deleteAccountStorage----

az storage account delete -n $AccountName -g $ResourceGroupName -y

echo deleteCdnProfile ----

az cdn profile delete -g $ResourceGroupName -n $ProfileName 




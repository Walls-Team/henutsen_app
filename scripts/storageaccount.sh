ResourceGroupName="henutsen-web-rg"
AccountNameCo="henutsenstorageaccountco"
AccountNameCom="henutsenstorageaccount"
urlAccount="https://$AccountName.blob.core.windows.net/\$web"
Location="eastus"
path="/index.html" 

echo login

az login -u jmolina@audisoft.com -p 9o+PA1cXh*

echo deleteAccountStorage----

az storage account delete -n $AccountName -g $ResourceGroupName -y

echo create accountStorage----

az storage account create -n $AccountName -g $ResourceGroupName -l $Location --sku Standard_LRS  --kind=StorageV2 --access-tier=Hot

echo createBlob----

az storage blob service-properties update --account-name $AccountName --static-website --404-document error-document-name --index-document index.html

echo uploadFile----

az storage blob upload-batch -s $1 -d $urlAccount 


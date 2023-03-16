
# Download dod pki certificates
wget https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_DoD.zip &&
unzip unclass-certificates_pkcs7_DoD &&
# change into the newly created certificate directory
cd certificates_pkcs7_v5_11_dod &&
# import all of the p7b files into the trust store
for n in *.p7b; do certutil -d sql:$HOME/.pki/nssdb -A -t TC -n $n -i $n; done ;
# display status of installed certs on machine
certutil -d sql:$HOME/.pki/nssdb/ -L &&
cd $HOME
# add CAC module to opensc
modutil -dbdir sql:.pki/nssdb/ -add “CAC_Module” -libfile /usr/lib64/pkcs11/p11-kit-client.so &&
mkdir DODcerts &&
mv unclass-* DODcerts &&
echo "All done!"

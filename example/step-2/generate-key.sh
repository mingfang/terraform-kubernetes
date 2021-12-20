ssh-keygen -f key -m pem
openssl rsa -in key -outform pem > key.pem
chmod 600 key.pem
rm key
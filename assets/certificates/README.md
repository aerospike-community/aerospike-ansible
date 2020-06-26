# Certificate Generation

The CA certificates and keys in this directory have been pre-generated for the purpose of supporting TLS setup

Recommend, unless you have good reason not to, go leave as is.

If you do need to re-generate

Run certificates-create.sh ( to do this remove everything in this folder other than this script and the README )

Enter 4+ password as the PEM phrase - this secures the CA key ( you will need to do this twice )

You will then see

```
CA certificate not found so generating CA certificate
-----------------------------------------------------
```
Here you are setting up the CA ( Certificate Authority ). You will get the following prompts

```
Country Name (2 letter code) [UK]:
State or Province Name (full name) [London]:
Locality Name (eg, city) [London]:
Organization Name (eg, company) [Aerospike]:
Organizational Unit Name (eg, section) [Ansible Deployment]:
Common Name [aerospike_ansible_demo_cluster]:
Email Address [demo@aerospike.com]:
```

Accept defaults for country name,state, locality, org name, unit name ( not that it matters too much ), email. You can set the common name to whatever you like, first time.

Next you will see
```
Removing certificates previously signed

Server certificates not found - generating
------------------------------------------
```
Here you are generating the server certificate, and getting it signed by the CA you just generated. You will get the following prompts
```
Country Name (2 letter code) [UK]:
State or Province Name (full name) [London]:
Locality Name (eg, city) [London]:
Organization Name (eg, company) [Aerospike]:
Organizational Unit Name (eg, section) [Ansible Deployment]:
Common Name [aerospike_ansible_demo_cluster]:
Email Address [demo@aerospike.com]:
```
Again, it doesn't matter too much what you choose, except the common name should be the same as the tls_name parameter in group_vars/all.yml - otherwise the crypto will not work.

You will be prompted for the pass-phrase you entered above

Answer y to 'Sign the Certificate'

Answer y to '1 out of 1 certificate requests certified, commit'

A full log of usage of this script given below
```
############################################################
IMPORTANT
This script is intended for test, not production use. It may delete or upsert important files, or not set them up sufficiently securely
############################################################

CA certificate not found so generating CA certificate
-----------------------------------------------------

Generating a 2048 bit RSA private key
................................................+++
....+++
writing new private key to '/Users/ken/repos/aerospike-solutions-misc/ken-tune/aerospike-ansible/assets/certificates/private/ca.key'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [UK]:
State or Province Name (full name) [London]:
Locality Name (eg, city) [London]:
Organization Name (eg, company) [Aerospike]:
Organizational Unit Name (eg, section) [Ansible Deployment]:
Common Name [aerospike_ansible_demo_cluster]:aerospike_ansible_demo_ca
Email Address [demo@aerospike.com]:

Removing certificates previously signed

Server certificates not found - generating
------------------------------------------

Generating a 2048 bit RSA private key
.........+++
..................................................+++
writing new private key to '/Users/ken/repos/aerospike-solutions-misc/ken-tune/aerospike-ansible/assets/certificates/private/server.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [UK]:
State or Province Name (full name) [London]:
Locality Name (eg, city) [London]:
Organization Name (eg, company) [Aerospike]:
Organizational Unit Name (eg, section) [Ansible Deployment]:
Common Name [aerospike_ansible_demo_cluster]:
Email Address [demo@aerospike.com]:
Using configuration from /Users/ken/repos/aerospike-solutions-misc/ken-tune/aerospike-ansible/assets/certificates/openssl.cnf
Enter pass phrase for /Users/ken/repos/aerospike-solutions-misc/ken-tune/aerospike-ansible/assets/certificates/private/ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 4096 (0x1000)
        Validity
            Not Before: Apr 24 13:52:35 2020 GMT
            Not After : Apr 24 13:52:35 2021 GMT
        Subject:
            countryName               = UK
            stateOrProvinceName       = London
            localityName              = London
            organizationName          = Aerospike
            organizationalUnitName    = Ansible Deployment
            commonName                = aerospike_ansible_demo_cluster
            emailAddress              = demo@aerospike.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                A2:72:0C:1A:E2:76:B5:A7:E3:9D:52:98:F5:B3:D5:F1:2C:C7:51:EB
            X509v3 Authority Key Identifier: 
                keyid:DE:E0:73:34:01:81:A1:B8:1C:8F:80:BE:EB:F8:16:48:FA:11:AC:73

Certificate is to be certified until Apr 24 13:52:35 2021 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```





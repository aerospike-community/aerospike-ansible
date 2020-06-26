#!/bin/bash

# With thanks to https://discuss.aerospike.com/t/how-to-generate-a-self-signed-tls-certificates/5050
echo "############################################################"
echo "IMPORTANT"
echo "This script is intended for test, not production use. It may delete or upsert important files, or not set them up sufficiently securely"
echo "############################################################"
echo
OPENSSL_DIR=$(pwd)

#rm -rf $OPENSSL_DIR
# Will attempt to create a directory with supplied name if not available using the -p (create parents) option
# Returns 0 if successful, non-zero if not
safe_mkdir(){
        DIR=$1
        if [ ! -d ${DIR} ]
        then
                mkdir -p $DIR
                return $?
        else
                return 0
        fi
}

safe_rm(){
	FILE=$1
	if [ -f $FILE ]
	then
		rm $FILE
	fi

}

safe_mkdir ${OPENSSL_DIR}
safe_mkdir ${OPENSSL_DIR}/certs
safe_mkdir ${OPENSSL_DIR}/crl
safe_mkdir ${OPENSSL_DIR}/newcerts
safe_mkdir ${OPENSSL_DIR}/private

chmod 700 ${OPENSSL_DIR}/private
touch ${OPENSSL_DIR}/index.txt

if [ ! -f ${OPENSSL_DIR}/serial ]
then
	echo 1000 > ${OPENSSL_DIR}/serial
fi

cat << EOF > ${OPENSSL_DIR}/openssl.cnf
HOME                    = .
RANDFILE                = $ENV::HOME/.rnd
[ ca ]
default_ca      = CA_default            # The default ca section
[ CA_default ]
dir             = ${OPENSSL_DIR}                # Where everything is kept
certs           = ${OPENSSL_DIR}/certs            # Where the issued certs are kept
crl_dir         = ${OPENSSL_DIR}/crl              # Where the issued crl are kept
database        = ${OPENSSL_DIR}/index.txt        # database index file.
new_certs_dir   = ${OPENSSL_DIR}/newcerts         # default place for new certs.
certificate     = ${OPENSSL_DIR}/certs/ca.crt     # The CA certificate
serial          = ${OPENSSL_DIR}/serial           # The current serial number
crlnumber       = ${OPENSSL_DIR}/crlnumber        # the current crl number
crl             = ${OPENSSL_DIR}/crl.pem          # The current CRL
private_key     = ${OPENSSL_DIR}/private/ca.key   # The private key
RANDFILE        = ${OPENSSL_DIR}/private/.rand    # private random number file
x509_extensions = usr_cert              # The extensions to add to the cert
name_opt        = ca_default            # Subject Name options
cert_opt        = ca_default            # Certificate field options
default_days    = 365                   # how long to certify for
default_crl_days= 30                    # how long before next CRL
default_md      = default               # use public key default MD
preserve        = no                    # keep passed DN ordering
policy          = policy_match
[ policy_match ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
[ req ]
default_bits            = 2048
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions = v3_ca # The extensions to add to the self signed cert
string_mask = utf8only
[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = UK
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = London
localityName                    = Locality Name (eg, city)
localityName_default            = London
0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = Aerospike
organizationalUnitName          = Organizational Unit Name (eg, section)
organizationalUnitName_default  = Ansible Deployment
commonName                      = Common Name
commonName_default				= aerospike_ansible_demo_cluster
commonName_max                  = 64
emailAddress                    = Email Address
emailAddress_default			= demo@aerospike.com
emailAddress_max                = 64
[ req_attributes ]
#challengePassword               = A challenge password
#challengePassword_min           = 4
#challengePassword_max           = 20
#unstructuredName                = An optional company name
[ usr_cert ]
basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
[ crl_ext ]
authorityKeyIdentifier=keyid:always
[ proxy_cert_ext ]
basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
proxyCertInfo=critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo
EOF

# Create your own CA certificate and key if they don't exist already
if [ ! -f ${OPENSSL_DIR}/private/ca.key -o ! -f ${OPENSSL_DIR}/certs/ca.crt ]
then
	echo CA certificate not found so generating CA certificate
	echo -----------------------------------------------------
	echo	
	openssl req -config ${OPENSSL_DIR}/openssl.cnf -new -x509 -days 1825 -extensions v3_ca -keyout ${OPENSSL_DIR}/private/ca.key -out ${OPENSSL_DIR}/certs/ca.crt
	echo 
	echo Removing certificates previously signed
	safe_rm ${OPENSSL_DIR}/private/server.key
	safe_rm ${OPENSSL_DIR}/certs/server.crt
	echo
else
	echo CA already exists - not re-creating
fi

if [ ! -f ${OPENSSL_DIR}/private/server.key -o ! -f ${OPENSSL_DIR}/certs/server.crt ]
then
	echo Server certificates not found - generating
	echo ------------------------------------------
	echo
	# Creating a new certificate request
	openssl req -config ${OPENSSL_DIR}/openssl.cnf -new -nodes -days 365 -keyout ${OPENSSL_DIR}/private/server.key -out ${OPENSSL_DIR}/server.csr
	# Signing it
	openssl ca -config ${OPENSSL_DIR}/openssl.cnf -policy policy_anything -out ${OPENSSL_DIR}/certs/server.crt -infiles ${OPENSSL_DIR}/server.csr
else
	echo Server certificates exist - not-recreating. Delete certs/server.crt \& private/server.key if you want to recreate
fi
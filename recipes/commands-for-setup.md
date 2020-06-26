# Commands for setup

These commands can be used on an Ubuntu instance to set up the pre-requisites required for aerospike-ansible

## Pip install

Comes as standard with Python 2.8+ but you may have a previous version

```
sudo apt-get update
sudo apt-get -y install python-pip
sudo pip install -U pip
```

## Virtualenv install

virtualenv is useful to localize your Python library installs ratehr than installing system wide

```
pip install virtualenv
pip install boto
pip install boto3
pip install ansible
```

## AWS CLI install

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws configure
```

## SSH

Ansible makes all its calls over ssh. Make sure it uses the key you specify

```
echo "IdentitiesOnly=yes" >> ~/.ssh/config
chmod 644 !$
```






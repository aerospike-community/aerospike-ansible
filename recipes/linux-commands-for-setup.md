# Commands for Linux Setup

These commands can be used on an Debian instance to set up the pre-requisites required for aerospike-ansible. You can create such an instance virtually using Vagrant via (from an empty directory)

```bash
vagrant init debian/stretch64
vagrant up
vagrant ssh
```

## Pip install

pip, the package installer for python comes as standard with Python 2.8+ but you may have a previous version. To install pip, and upgrade to a recent version do

```bash
sudo apt-get update
sudo apt-get -y install python-pip curl unzip git
sudo pip install -U pip
```

Note you may have difficulty with this last command. If you do, remove your virtual machine, if you are using one, and start again, but do not do ```pip install -U pip```

## Pre-requisites

If you are installing python pre-requisites globally, do

```bash
sudo pip install boto boto3 ansible
```

If you would prefer not to do this see the virtualenv section below.

## virtualenv install

Managing python dependencies is non-trivial and keeping dependencies local helps avoid causing problems elsewhere. If you wish to do this, the [virtualenv](https://pypi.org/project/virtualenv/) tool is very helpful. First install the virtualenv tool itself

```bash
sudo pip install virtualenv
```

In order to create and manage virtual environments, virtualenv creates configuration information under a named directory. Run the command below to create this.

```bash
virtualenv /path/to/your/virtualenv/directory
```

Note this path does not need to exist - virtualenv will create it, and any parent directories for you.

Now activate your environment. **Note you will ALWAYS need to do this before running playbooks, otherwide dependencies won't be correctly found**

```bash
source /path/to/your/virtualenv/directory/bin/activate
```

Your command prompt will change - the name of your virtualenv directory will be shown as below.

```bash
(venv-directory-name) vagrant@stretch:~/aerospike-ansible$ 
```

You can now install your python dependencies locally (so no sudo required)

```bash
pip install boto boto3 ansible
```

You can see that your environment is localised - ```which pip``` for example will show 

``````bash
/path/to/your/virtualenv/directory/bin/pip
``````

To deactivate your virtual environment (and revert to global python dependencies) just type ```deactivate```. Your command prompt will change to it's previous state.

## AWS CLI install

This to add your AWS credentials.

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws configure
```

See [https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for details on what ```aws configure``` expects

## SSH

Ansible makes all its calls over ssh. Make sure it uses the key you specify

```
echo "IdentitiesOnly=yes" >> ~/.ssh/config
chmod 644 !$
```

## Playbooks

Install the Ansible playbooks and move to the playbook directory

```bash
git clone https://github.com/aerospike-examples/aerospike-ansible
cd aerospike-ansible
```

## Running the playbooks

You can now use the supplied playbooks as per the main [README](../README.md). For instance

```bash
(venv-directory-name) vagrant@stretch:~/aerospike-ansible$ ansible-playbook aws-setup-plus-aerospike-install.yml 
```






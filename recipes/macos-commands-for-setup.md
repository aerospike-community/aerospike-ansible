# Commands for MacOS Setup

These commands can be used on MacOS to set up the pre-requisites required for aerospike-ansible.

MacOS ships with its own version of python (2.7.10 for me on macOS 10.14.6). Unfortunately this is sufficiently out of date to make compatibility with Ansible a problem. You are generally strongly advised not to modify the native version however. We work round this by installing a local python version using the [pyenv](https://github.com/pyenv/pyenv) utility.

First install [brew](https://brew.sh/) if you don't have it already. Brew is a package manager for MacOS.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Next install pyenv which allows multiple versions of python to co-exist on MacOS.

```bash
brew install pyenv
```

Use this to install a sufficiently advanced version of python. I've found 2.7.13 works. The next two commands set the environment up so the required version of python is the one being used.

```bash
pyenv install 2.7.13
pyenv global 2.7.13
eval "$(pyenv init -)"
```

Now we upgrade pip, the package installer for python to get the most recent version (likely you will have an out of date one, or none at all). Note this will be entirely local to this environment.

```bash
pip install --upgrade pip
```

## virtualenv install

Managing python dependencies is non-trivial and keeping dependencies local helps avoid causing problems elsewhere. If you wish to do this, the [virtualenv](https://pypi.org/project/virtualenv/) tool is very helpful. First install the virtualenv tool itself

```bash
pip install virtualenv
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
(venv-directory-name) Kens-MacBook-Pro:~ kentune$ 
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

## AWS CLI Install

This to add your AWS credentials.

```bash
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle-1.16.312.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
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
(venv-directory-name) Kens-MacBook-Pro:~ kentune$ ansible-playbook aws-setup-plus-aerospike-install.yml 
```


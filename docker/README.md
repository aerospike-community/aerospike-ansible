# Aerospike Ansible Client Container

Setting up the pre-requisities for Aerospike Ansible is non-trivial and it is possible to run into compatibility issues between OS versions, python versions, boto, ansible and privilege issues.

Providing a pre-built container to act as a client can help reduce the probability of these issues occurring.

It is assumed that you have [Docker](http://docker.com) installed locally.

## Obtaining the client image

There are three ways of doing this

### 1. Build it yourself

 To do this, you need to be in the same directory as this README.

```bash
docker build -t aerospike-ansible-client-image .
```

 This builds the image locally, without baking in AWS access credentials.

Note the ```.``` in the above command means 'current directory' so you can build from any location, so long as you replace the ```.``` with the path to the directory containing this README ( and therefore the required Dockerfile ). ```aerospike-ansible-client-image``` is the name we are giving to the image. Any name can be used, so long as usage is consistent across commands.

### 2. Pull from a repository

A pre-build client image is available from Docker Hub. This can be obtained using the following command.

```bash
docker pull ktune/aerospike-ansible-client-image
```

To keep things simple, let's tag this so it gets the image name we want. I'd do the following

```bash
docker tag ktune/aerospike-ansible-client-image aerospike-ansible-client-image
```

### 3. Build it yourself, including your AWS credentials

The images above do not include your AWS credentials. You can create an image that does by using the following command

```bash
docker build --build-arg AWS_ACCESS_KEY=YOUR_ACCESS_KEY_HERE \
--build-arg AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY_HERE -t aerospike-ansible-client-image .
```

This avoids you having to go through the ```aws configure``` step (see below) every time you start your image.

## Running the image

You run the image using 

```bash
docker run -d --name aerospike-ansible-client aerospike-ansible-client-image
```

Here I am running the image ```aerospike-ansible-client-image``` but giving the running container the name of ```aerospike-ansible-client```. As above, you can change these names, so long as you use them consistently.

You can obtain the image and run it in one step, if pulling from a repository

```bash
docker run -d --name aerospike-ansible-client ktune/aerospike-ansible-client-image
```

Once you have a running image you can log into it.

```bash
docker exec -it aerospike-ansible-client bash
```

You will see a command prompt that looks something like

```bash
asbuild@8a019d4e77ac:~/aerospike-ansible$
```

If you have pulled the image from DockerHub consider running ```git pull``` to check for project updates at the above command line prompt.

## AWS Configure

If you have built your image using approaches 1 or 2 in the 'Obtaining the client image' section then you will need to add your AWS credentials using the AWS Configure utility. Type

```bash
aws configure
```

at the container command prompt above and enter your AWS Access key, AWS Secret access key and preferred region. See [https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for more details.

## Running the playbooks

You can now use the supplied playbooks as per the main [README](../README.md). For instance

```bash
asbuild@37c010eff997:~/aerospike-ansible$ ansible-playbook aws-setup-plus-aerospike-install.yml 
```




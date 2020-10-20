# One touch AWS Cluster Setup using Ansible

## Overview

The playbooks in this repo allow you to *configurably* set up, on AWS

- An Aerospike cluster
- Aerospike java benchmarking clients 
- The Aerospike Prometheus/Grafana monitoring stack

This includes setup of all the necessary AWS VPC infrastructure.

## Quick Start

[Install ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

[Install boto](https://crunchify.com/how-to-install-boto3-and-set-amazon-keys-a-python-interface-to-amazon-web-services/) - the python wrapper for the AWS SDK. You may run into compatibility problems - python versions / boto versions. I made use of this [tweak](https://www.zigg.com/2014/using-virtualenv-python-local-ansible.html) and am running under a [virtualenv](https://docs.python-guide.org/dev/virtualenvs/). If you set up your own virtualenv and install boto into it you should be OK as I've baked the other things into the settings in this repo

You need your AWS credentials on disk as per https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html. The user you use will need the AmazonEC2FullAccess roles.

The SSH change given in [SSH](#ssh) is recommended

A full list of commands to set up is given in [commands-for-setup.md](recipes/commands-for-setup.md)

Once you have done all this

### One touch setup

```ansible-playbook aws-setup-plus-aerospike-install.yml```

will set up an Aerospike cluster on AWS that you can access from your own machine. By default, this will be 3 nodes in 3 separate AZs, c5d.large with the ephemeral disk partitioned 4 ways.

```ansible-playbook aerospike-java-client-setup.yml```

will set up a configured java benchmarking client allowing immediate use (IPs taken care of)

```ansible-playbook aerospike-monitoring-setup.yml```

will set up the monitoring stack including Prometheus and Grafana. You can then simply access the exposed Grafana endpoint.

## Video

A [video](https://youtu.be/fWKACehyJHc) showing end to end setup of the full Aerospike cluster/client/monitoring stack on a fresh Vagrant instance is available.

The first 10min deal with setting up the pre-requisites (virtualenv/ansible/boto/IAM) with the remainder showing use of the playbooks.

## Other playbooks

- ```ansible-playbook aws-setup.yml``` creates the AWS VPC infrasturcture and the cluster instances
- ```ansible-playbook install-aerospike.yml``` just does the Aerospike install (```aws-setup-plus-aerospike-install.yml``` simply calls ```aws-setup.yml``` followed by ```install-aerospike.yml``` )
- ```ansible-playbook remove-aerospike.yml``` will remove the Aerospike install (you can use this + ```install-aerospike.yml``` to change your install without having to rebuild the instances)
- ```aws-teardown.yml``` removes all AWS hosts and VPC components
- ```reload-config.yml``` will upload a new aerospike.conf to all hosts and re-start - useful if iteratively creating a new conf file.

## Configuration Options

Everything you are likely to want to change can be found in  ```vars/cluster-config.yml``` 

- **instance_type** - default = c5d.large
- **cluster_hosts_per_az** - default = 1
- **partitions_per_device** - default = 4 ( nvme volumes will automatically be partitioned for you )
- **enterprise** - default = false to allow single click setup of Community. If true, a feature key location must be specified ( see below )
- **encryption_at_rest** - default = false. If true ```aerospike.conf``` will be appropriately modified and a key file generated
- **tls_enabled** - default = false. If true ```aerospike.conf``` will be appropriately modified and all certificates appropriately located. Connecting clients will be appropriately configured.
- **strong_consistency** - default = false. If true ```aerospike.conf``` will be appropriately modified. The roster will be automatically set for you, with rack awareness, assuming each subnet constitutes a separate 'rack'
- **all_flash** - default = false. If true, first partition on each disk, so (1 / partitions_per_device) of the available space, will be allocated for index on device. Both this and partition-tree-sprigs will usually require custom setting. For accurate sizing consult [all flash sizing](https://www.aerospike.com/docs/operations/configure/namespace/index/index.html#flash-index-calculations-summary)
- **monitoring_enabled** - default = false. If true the Aerospike Prometheus agent will be installed, configured and started on the cluster nodes.
- **aerospike_distribution** - default = el6. Determines the distribution used.
- **aerospike_version** - default = latest
- **ami_locator_string** - the latest version of the AMZN2 AMI is used ( dynamically looked up). Other builds can be used by modifying this string. 
- **replication_factor** - default = 2
- **aerospike_mem_pct** - fraction of available memory to allocate to the 'test namespace'. Default = 80%
- **feature_key** - path for an Enterprise feature key. Undefined by default so the setup works out of the box.

On the AWS side you can modify via ```vars/aws-config.yml```

- **aws_region** - default = us-east-1
- **cluster_az_list** - default = [a,b,d] - c can be a little flaky
- **client_az_list** - default is first az in the cluster az list

## Command Line Options

All the configuration options above can be modified via the command line using the ```--extra-vars``` option and a JSON formatted argument. e.g.

```ansible-playbook aws-setup-plus-aerospike-install.yml --extra-vars="{'aerospike-version':'4.8.0.3', instance_type:'c5d.2xlarge'}"```

Alternatively, ```vars/cluster-config.yml``` can be modified.

To use enterprise a feature key argument must be supplied, as well as the specification ```enterprise = true```

```ansible-playbook aws-setup-plus-aerospike-install.yml --extra-vars="{'enterprise':true,'feature_key':'/path/to/my/features.conf'}"```

## aerospike.conf

The template in ```assets/aerospike.conf.j2``` has the ip addresses of the hosts injected and the device names. If you wish to use a different configuration, edit this file.

## What gets created? 

- Dedicated SSH Key
- VPC
- Subnets
- Routing
- Security Group
- Selects most recent AMI in a given category ( e.g. Amazon Linux 2 )
- Creates instances using selected AMI
- Creates a local 'quick access' script ( lets you get into your cluster via ```scripts/cluster-quick-ssh.sh 1/2/3``` etc )
- Partitions nvme volumes ( # of partitions per disk is configurable )
- Takes an Aerospike configuration file ( editable ) and injects AWS local IP addresses of instances for discovery purposes
- Adds partitioned volumes as devices to namespace
- Allows choice of Enterprise / Community
- Sources features.conf
- Installs Aeropspike ( version / distribution can be specified )
- Starts Aerospike

## Utilities

As above a script gets created allowing ready access to the cluster

```./scripts/cluster-quick-ssh.sh 1``` will get you into node 1 in the cluster and so on. Avoids tedious copying of IP addresses. Note that this will use the key generated by the playbook which is locally in ```.aws.pem``` - your own keys are not used.

```source scripts/ip-address-list.sh``` to allow referencing of IP addresses thusly at the command line

```echo ${AERO_CLUSTER_IPS[0]}```

## Using the benchmarking client

```./scripts/client-quick-ssh.sh 1``` logs you into your client instance

```cd aerospike-client-java/benchmarks```

```./as-benchmark-w.sh``` will load 10m keys into your cluster
```./as-benchmark-rw.sh``` will run a 50/50 workload

Tuning parameters such as rate, key set size, read/write workload proportion, thread count, object spec can all be set via ```./as-benchmark-common.sh```

Necessary TLS configuration including installation of a CA and use of correct flags will be automatically configured if ***tls_enabled*** is set to true.

## Using the monitoring stack

At the end of the output for ```ansible-playbook aerospike-monitoring-setup.yml``` you will see the message

```Grafana dashboard available at http://<IP>:4000```

Copy paste this into your browser. User/Pass is admin/admin. Changing the password is recommended.

Select Home -> Aerospike -> Namespace View to see your first dashboard.

Follow the instructions in [Using the benchmarking client](#using-the-benchmarking-client) to generate read/write activity that you can watch

## Recipes

In the recipe section are some assets allowing support of one touch rolling upgrades and cluster moves - as used in my Summit 2020 talk. Watch this space for full scripts.

## GCP

These scripts can be used to create a full Aerospike stack in GCP. The Ansible tooling doesn't allow easy creation of instances however.

Start by creating a host in GCP to act as your Ansible host and do the setup described in [Quick Start](#quick-start).

Make use of the ```gcp``` branch of this repo as some small tweaks were needed to get things to work.

Then create your cluster/client/monitoring instances maybe using VM templates (a GCP thing) to ensure consistency, give them names and then add the host names to 
the ```inventory/hosts``` file. Examples of what to do are given in the ```inventory/hosts``` in the ```gcp``` branch.

## TLS

TLS enabled Aerospike is built using pre-built key pairs, which are exposed in this project - see [private](assets/certificates/private). These keys are not to be used for production purposes. You will however see instructions in [certificates](assets/certificates) which tell you how to create your own, which can be used to replace the ones provided.

To use aql with TLS enabled

```
aql --tls-enable --tls-name=aerospike_ansible_demo_cluster --tls-cafile=/etc/aerospike/certs/ca.crt -p 4333
```

Similarly, for asadm

```
asadm --tls-enable --tls-name=aerospike_ansible_demo_cluster --tls-cafile=/etc/aerospike/certs/ca.crt -p 4333
```

and asinfo

```
asinfo --tls-enable --tls-name=aerospike_ansible_demo_cluster --tls-cafile=/etc/aerospike/certs/ca.crt -p 4333 <YOUR_COMMAND_HERE>
```


## SSH

If you see

Received disconnect from 18.207.231.181 port 22:2: Too many authentication failures

or similar when using Ansible try adding

IdentitiesOnly=yes to your .ssh/config file

## Other

Disk partitioning relies on devices being named /dev/nvme* & we ignore nvme0 as this is usually the boot volume.

Dash is very handy for Ansible documentation

## Feedback

Please use the [issues](../../issues) feature.

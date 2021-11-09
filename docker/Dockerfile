FROM debian:stretch-slim 

# Build varialbes - meaning should be clear
# Placeholders have been provided for the aws access key and secret access key
# These would either be overridden by providing build arguments at the command line
# or by executing aws configure
# ==================================================================================

ARG RUN_TIME_USER=asbuild
ARG RUN_TIME_GROUP=asbuild
ARG AEROSPIKE_RUN_DIR=/home/${RUN_TIME_USER}
ARG AEROSPIKE_ANSIBLE_SUB_DIR=aerospike-ansible
ARG AWS_ACCESS_KEY=XXXXXX
ARG AWS_SECRET_ACCESS_KEY=XXXXXX

# Install Binaries
# ==================================================================================

RUN apt-get update
RUN apt-get -y install python-pip curl unzip git vim
RUN pip install -U pip
RUN pip install virtualenv boto boto3 ansible ec2
RUN cd /tmp && \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install && \
cd -

# Set up run time user
# ==================================================================================

RUN mkdir $AEROSPIKE_RUN_DIR && \
groupadd $RUN_TIME_GROUP && \
useradd -u 10001 $RUN_TIME_USER -g $RUN_TIME_GROUP && \
mkdir $AEROSPIKE_RUN_DIR/.ssh && \
mkdir $AEROSPIKE_RUN_DIR/.aws && \
chown -R $RUN_TIME_USER:$RUN_TIME_GROUP $AEROSPIKE_RUN_DIR && \
echo "IdentitiesOnly=yes" >> $AEROSPIKE_RUN_DIR/.ssh/config && \
chmod 644 $AEROSPIKE_RUN_DIR/.ssh/config

RUN ansible-galaxy role install sleighzy.zookeeper sleighzy.kafka -p $AEROSPIKE_RUN_DIR/.ansible/roles

# Clone the Aerospike Ansible project
# ==================================================================================

RUN git clone https://github.com/aerospike-examples/aerospike-ansible ${AEROSPIKE_RUN_DIR}/${AEROSPIKE_ANSIBLE_SUB_DIR}

# Set up the AWS credentials
# As above this means the credentials can be baked in at build time
# But they can be overridden at run time
# ==================================================================================

RUN echo [default] >> $AEROSPIKE_RUN_DIR/.aws/credentials && \
echo "aws_access_key_id = $AWS_ACCESS_KEY" >> $AEROSPIKE_RUN_DIR/.aws/credentials && \
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> $AEROSPIKE_RUN_DIR/.aws/credentials

# Make sure all the permissions are correct for the run time user
# ==================================================================================

RUN chown -R $RUN_TIME_USER:$RUN_TIME_GROUP $AEROSPIKE_RUN_DIR

USER $RUN_TIME_USER
WORKDIR ${AEROSPIKE_RUN_DIR}/${AEROSPIKE_ANSIBLE_SUB_DIR}

# Keep it running
ENTRYPOINT ["tail", "-f", "/dev/null"]

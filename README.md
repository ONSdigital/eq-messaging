# eq-messaging
Repository for holding RabbitMQ configuration

# Creating a Fully Clustered HA RabbitMQ with Ansible

1. Create 2 EC2 Ubuntu instances (set an appropriate security group and key pair)
2. Add a Route53 entry for test-rabbitmq1.eq.ons.digital and test-rabbitmq2.eq.ons.digital
3. Point the entries at the above EC2 instances
4. Log on to each EC2 instance
    a. Modify the host name to either rabbitmq1 or rabbitmq2 making sure to match the correct route 53 entry
    ```
        sudo vi /etc/hostname
        sudo hostname -F /etc/hostname
    ```
    b. Add entries in the /etc/hosts on both instances so that they know where each other is located
        sudo vi /etc/hosts
         e.g.  
         ```
                172.31.1.113 test-rabbitmq1.eq.ons.digital test-rabbitmq1
                172.31.1.112 test-rabbitmq2.eq.ons.digital test-rabbitmq2
         ```
5. Install ansible locally using either pip or homebrew (you can add it to the boxen manifest).
6. Modify your /etc/ansible/hosts file, adding these entries:

```
sudo tee /etc/ansible/hosts <<EOF
test-rabbitmq1.eq.ons.digital
test-rabbitmq2.eq.ons.digital
EOF

```

7. Install the alexeymedvedchikov.rabbitmq role from Ansible galaxy (this is where the magic happens)

```
sudo ansible-galaxy install alexeymedvedchikov.rabbitmq
```

8. Run the rabbit mq playbook in this repository, this should provision the two EC2 instances, cluster them together and
setup the HA capability so that queues replicated to each other.

```
ansible-playbook -i 'test-rabbitmq1.eq.ons.digital,test-rabbitmq2.eq.ons.digital'  --private-key digital-eq-keypair.pem ansible/rabbitmq-cluster.yml --extra-vars "deploy_env=test, deploy_dns=eq.ons.digital"
```

## How to run post install test

To test the created message queue, use the python scripts included. First install the dependencies using
```
pip install -r requirements.txt
```

Then run the following to put a message on the queue and then to read that message off the queue:

```
python send.py
python receive.py
```

This will then print out to stdout, "[x] Received X", where X will be the message from the queue.

## Testing with Vagrant

This repo includes a Vagrant file that brings up a single Ubuntu Trusty machine (14.0.4LTS) to test the ansible scripts against.

To install Vagrant on a mac:
```
brew cask install virtualbox
brew cask install vagrant
```
And then to install the Ansible dependencies:
```
sudo ansible-galaxy install jnv.unattended-upgrades

```

You can then issue `vagrant up` which will create a new VM, provision it with the role.yml and allow you to ssh into the machine to check the state has been correctly set. This gives a useful target for testing and developing without having to recreate an entire infrastructure environment.

To test the rsyslog capabilities, make sure you have tcpdump installed and run the
following in a terminal:

```
ifconfig
```
Look for the first device named 'vboxnet' followed by a number.
Then plug that interface name into the following:

```
sudo tcpdump -i <INTERFACE_NAME> -X -v 'udp port 514'
```

This will dump the feed from the rsyslogd collector so that you can see the logs
being sent off the VM. To generate extra traffic try becoming root inside your
vagrant box to create audit events.

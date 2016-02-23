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

7. Install the warrenbailey.rabbitmq role from Ansible galaxy (this is where the magic happens)

```
sudo ansible-galaxy install warrenbailey.rabbitmq
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

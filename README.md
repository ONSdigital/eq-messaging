# eq-messaging
Repository for holding RabbitMQ configuration

# Creating a Fully Clustered HA RabbitMQ with Ansible

1. Create 2 EC2 Ubuntu instances (set an appropriate security group and key pair)
2. Add a Route53 entry for rabbitmq1.eq.ons.digital and rabbitmq2.eq.ons.digital
3. Point the entries at the above EC2 instances
4. Log on to each EC2 instance
    a. Modify the host name to either rabbitmq1 or rabbitmq2 making sure to match the correct route 53 entry
        sudo vi /etc/hostname
        sudo hostname -F /etc/hostname
    b. Add entries in the /etc/hosts on both instances so that they know where each other is located
        sudo vi /etc/hosts
         e.g.   172.31.1.113 rabbitmq1.eq.ons.digital rabbitmq1
                172.31.1.112 rabbitmq2.eq.ons.digital rabbitmq2

5. Install ansible locally using either pip or homebrew (you can add it to the boxen)
6. Modify your /etc/ansible/hosts file and add these entries:
    rabbitmq1.eq.ons.digital
    rabbitmq2.eq.ons.digital

7. Install the warrenbailey.rabbitmq role from Ansible galaxy (this is where the magic happens)
    sudo ansible-galaxy install warrenbailey.rabbitmq

8. Run the rabbit mq playbook in this repository, this should provision the two EC2 instances, cluster them together and
setup the HA capability so that queues replicated to each other.
    ansible-playbook --private-key digital-eq-keypair.pem -v ansible/rabbitmq-cluster.yml
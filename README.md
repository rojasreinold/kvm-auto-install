# kvm-auto-install
Scripts to provision new server using kvm

makeFullVM.sh creates a vm on a kvm host using arguments kvm host, hostname, ip, ram, and disk parameters
  Example: $0 -k kvm1 -n test200 -i 10.0.0.10 -r 1024 -d 25
will create a host test200 with ip 10.0.0.10, ram 1024mb, and 25GB drive

It will also do some basic package install/configurations, add to ansible host file, and add to dns.

kvmHost directory belongs in the /root/bin of each kvm host host
ansibleHost directory belongs on the ansible host you run ansible on/makeFullVM.sh script


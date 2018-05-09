#!/bin/bash

KVM_HOST=""
VM_HOSTNAME=""
VM_IP=""
VM_RAM=1024
VM_DISK=25
FORCE_DELETE=""

#Get args
while getopts ":k:n:i:r:d:fh" optarg;
do
  case ${optarg} in
    k )
      KVM_HOST=${OPTARG}
      ;;

    n )
      VM_HOSTNAME=${OPTARG}
      ;;

    i )
      VM_IP=${OPTARG}
      ;;

    r )
      VM_RAM=${OPTARG}
      ;;
    d )
      VM_DISK=${OPTARG}
      ;;

    f )
      FORCE_DELETE="y"
      ;;

    h )
      echo " $0 creates a vm on a kvm host using arguments kvm host, hostname, ip, ram, and disk parameters"

      echo  -e "\nExample: \n$0 -k kvm1 -n test200 -i 10.0.0.10 -r 1024 -d 25\n"
      echo 'will create a host test200 with ip 10.0.0.10, ram 1024mb, and 25GB drive'
      exit 0
      ;;

    \? )
      echo "invalid option -${OPTARG}"
      exit 1
      ;;

    : )
      echo " invalid: -${OPTARG} requires an argument"
      exit 1
      ;;

  esac
done

if [[ -z ${KVM_HOST} ]]
then
  echo "You must set a kvm host with -k"
  exit 1
fi

if [[ -z ${VM_HOSTNAME} ]]
then
  echo "You must set a hostname with -n"
  exit 1
fi
 
if [[ -z ${VM_IP} ]]
then
  echo "You must set an ip with -i"
fi

if [[ -z $(echo ${VM_IP} | egrep "10\.([0-9]{1,3}\.){2}[0-9]{1,3}") ]]
then
  echo "Bad ip address exiting"
  exit 1
fi
COMMAND_ARGS=" -n ${VM_HOSTNAME} -i ${VM_IP} "

if [[ ! -z ${VM_RAM} ]]
then
  COMMAND_ARGS="${COMMAND_ARGS} -r ${VM_RAM} "
fi

if [[ ! -z ${VM_DISK} ]]
then
  COMMAND_ARGS="${COMMAND_ARGS} -d ${VM_DISK} "
fi

if [[ ! -z ${FORCE_DELETE} ]]
then
  COMMAND_ARGS="${COMMAND_ARGS} -f"
fi

ssh ansible@${KVM_HOST} "/home/ansible/bin/kickstartVM.sh ${COMMAND_ARGS} "
if [[ ! $? == 0 ]]
then
  echo "Couldn't create vm, exiting"
  exit 1
fi

echo "Adding host to dns"
/etc/ansible/updateServer/roles/updateDNSLocal/tasks/addToDNS.sh -n ${VM_HOSTNAME} -i ${VM_IP}
echo "Push DNS Changes"
ansible-playbook /etc/ansible/updateServer/updateDNSLocal.yml
echo "Waiting for VM to finish kickstarting"

ssh ansible@${KVM_HOST} "/home/ansible/bin/finishedKickstart.sh -n ${VM_HOSTNAME}"
echo "Wait for VM to restart "
ansible-playbook /etc/ansible/kvmProvision/wait_for.yml -i ${VM_IP},
ansible-playbook /etc/ansible/kvmProvision/setUpVM.yml -i ${VM_IP},

#Delete any occurance of VM_IP or VM_HOSTNAME in knownhosts
sed -i -r "/\b${VM_IP}\b/d" ~/.ssh/known_hosts
sed -i -r "/\b${VM_HOSTNAME}\b/d" ~/.ssh/known_hosts

#add to ansible hosts file

sed -i -r "/\b${VM_HOSTNAME}\b/d" /etc/ansible/hosts
sed -i -r "s/^#\[all\]/#[all]\n${VM_HOSTNAME}/g" /etc/ansible/hosts

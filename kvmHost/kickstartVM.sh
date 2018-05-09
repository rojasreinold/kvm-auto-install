#!/bin/bash
#create a vm dynamically
#Ran on kvm host


VM_HOSTNAME=""
VM_IP=""
VM_RAM=1024
VM_DISK=25
FORCE_DELETE=""

KICKSTART_FILES="/home/ansible/workspace/kickstartFiles"

while getopts ":n:i:r:d:fh" optarg;
do
  case ${optarg} in
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
      echo " $0 creates a vm using hostname, ip, ram, and disk parameters"
      echo "Example: $0 -n test200 -i 10.0.0.10 -r 1024 -d 25"
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

if [[ -z ${VM_HOSTNAME} ]]
then
  echo 'please enter a hostname with -n'
  exit 1
fi

if [[ -z ${VM_IP} ]]
then
  echo 'please enter an ip with -i'
  exit 1
fi


VM_EXISTS=$(sudo virsh list --all | grep -i -E "\b${VM_HOSTNAME}\b") 
if [[ ! -z ${VM_EXISTS} ]]
then
  if [[ -z ${FORCE_DELETE} ]]
    then
    echo "Looks like this host already exists"
    echo "If you want to delete old host re-run command with -f"
    exit 1  
  fi
  echo "Host exists but forcing creation"
  echo "Deleting old host"
  DOWN_OLDHOST=$(sudo virsh list --all | grep -i -E "\b${VM_HOSTNAME}\b" | grep "shut off")
  
  sudo virsh destroy ${VM_HOSTNAME}

  sleep 2
  sudo virsh undefine ${VM_HOSTNAME}
  sleep 2
  sudo rm /var/kvm/spool1/SVol${VM_HOSTNAME}.img
fi  

echo "removing any mention old host from known_hosts"
if [[ -f ~/.ssh/known_hosts ]]
then 
  sed -i "/${VM_HOSTNAME}/d" ~/.ssh/known_hosts
  sed -i "/${VM_IP}/d"  ~/.ssh/known_hosts
fi

echo "Setting up kickstart file"
cp ${KICKSTART_FILES}/ks-template.cfg ${KICKSTART_FILES}/ks-${VM_HOSTNAME}.cfg
sed -i -E "s/VM_HOSTNAME/${VM_HOSTNAME}/g" ${KICKSTART_FILES}/ks-${VM_HOSTNAME}.cfg
sed -i -E "s/VM_IP/${VM_IP}/g" ${KICKSTART_FILES}/ks-${VM_HOSTNAME}.cfg

echo "Setting up VM installation"
sudo qemu-img create -f raw /var/kvm/spool1/SVol${VM_HOSTNAME}.img ${VM_DISK}G

echo "Installation command:"
echo "sudo virt-install --noautoconsole --name=${VM_HOSTNAME} --disk path=/var/kvm/spool1/SVol${VM_HOSTNAME}.img --vcpu=1 --ram=${VM_RAM} --location=/usr/local/images/centos7 --network bridge=virbr6 --os-type=linux --os-variant=rhel7 --initrd-inject=${KICKSTART_FILES}/ks-${VM_HOSTNAME}.cfg -x ks=file:/ks-${VM_HOSTNAME}.cfg"

sudo virt-install --noautoconsole --name=${VM_HOSTNAME} --disk path=/var/kvm/spool1/SVol${VM_HOSTNAME}.img --vcpu=1 --ram=${VM_RAM} --location=/usr/local/images/centos7 --network bridge=virbr6 --os-type=linux --os-variant=rhel7 --initrd-inject=${KICKSTART_FILES}/ks-${VM_HOSTNAME}.cfg -x ks=file:/ks-${VM_HOSTNAME}.cfg

rm ${KICKSTART_FILES}/ks-${VM_HOSTNAME}.cfg

#!/bin/bash

VM_HOSTNAME=""

while getopts ":n:h" optarg;
do
  case ${optarg} in
    n )
      VM_HOSTNAME=${OPTARG}
      ;;

    h )
      echo " $0 Checks for about ten minutes if the vm came up"
      echo "Example: $0 -n test200 "
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

FINSHED_KICKSTART=$(sudo virsh list --all | grep -i -E "\b${VM_HOSTNAME}\b" | grep "shut off")

SLEPT_FOR=10
while [[ -z ${FINISHED_KICKSTART} ]]
do
  sleep 10
#  echo ${SLEPT_FOR}
  SLEPT_FOR=$((${SLEPT_FOR}+10))
  #Kickstart should take no more than ten minutes
  if [[ ${SLEPT_FOR} -gt 660 ]]
  then
    echo "Host has taken more than ten minutes to finish kickstarting"
    echo "Exiting"
    exit 1  
  fi

  if (( ${SLEPT_FOR} % 60 == 0 ))
  then
    echo "Host ${VM_HOSTNAME} has not come up for $((${SLEPT_FOR}/60)) minutes"
  fi

  FINISHED_KICKSTART=$(sudo virsh list --all | grep -i -E "\b${VM_HOSTNAME}\b" | grep "shut off")
done

echo "Kickstarted host ${VM_HOSTNAME} has finished installing!"
sudo virsh start ${VM_HOSTNAME}

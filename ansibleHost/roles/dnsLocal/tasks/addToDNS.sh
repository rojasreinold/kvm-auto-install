#!/bin/bash
#

VM_HOSTNAME=""
VM_IP=""

while getopts ":n:i:h" optarg;
do
  case ${optarg} in
    n )
      VM_HOSTNAME=${OPTARG}
      ;;

    i )
      VM_IP=${OPTARG}
      ;;


    h )
      echo " $0 add to ansible dns files"

      echo  -e "\nExample: \n$0 -n test200 -i 10.0.0.10 \n"
      echo 'will add the hostname/ip to db.reinoldrojas.com and db.10.0.0'
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
  echo "You must set a hostname with -n"
  exit 1
fi
 
if [[ -z ${VM_IP} ]]
then
  echo "You must set an ip with -i"
  exit 1
fi

echo "Deleting any previous host mention from db.reinoldrojas.com "
sed -i -E "/^${VM_HOSTNAME}.reinoldrojas.com./d" ../files/zones/db.reinoldrojas.com
sed -i -E "/^${VM_IP}/d" ../files/zones/db.reinoldrojas.com

VM_LAST_IP=$(echo "${VM_IP}" | cut -d"." -f4)
echo ${VM_LAST_IP}
echo "Deleteing any mention from PTR file"
sed -i -E "/^${VM_LAST_IP}\b/d" ../files/zones/db.10.0.0
sed -i -E "/^${VM_HOSTNAME}.reinoldrojas.com./d" ../files/zones/db.10.0.0

echo "Adding to db.10.0.0 file"
sed -i -r "s/^(; A records.*)/\1\n${VM_HOSTNAME}.reinoldrojas.com.\tIN\tA\t${VM_IP}/g" ../files/zones/db.reinoldrojas.com
sed -i -r "s/^(; PTR records.*)/\1\n${VM_LAST_IP}\tIN\tPTR\t${VM_HOSTNAME}/g" ../files/zones/db.10.0.0

$TTL	604800
@ 	IN	SOA	dns1.reinoldrojas.com. admin.reinoldrojas.com. (
		6	; Serial
	     604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800    ; Negative Cache TTL
	)

; NS records
	IN 	NS 	dns1.reinoldrojas.com.


; A records
programming.reinoldrojas.com.	IN	A	10.0.0.9
gitlab.reinoldrojas.com.	IN	A	10.0.0.14
testclient.reinoldrojas.com.	IN	A	10.0.0.13
testipa.reinoldrojas.com.	IN	A	10.0.0.12
router2.reinoldrojas.com. IN  A 10.0.0.6
testldap.reinoldrojas.com.	IN	A	10.0.0.12
test200.reinoldrojas.com.	IN	A	10.0.0.8
ansible.reinoldrojas.com.  IN  A 10.0.0.5
monitoring1.reinoldrojas.com.  IN  A 10.0.0.7
dhcp.reinoldrojas.com.		IN	A 	10.0.0.2
wordpress.reinoldrojas.com. 	IN	A 	10.0.0.17
kvm1.reinoldrojas.com. IN  A 10.0.0.1
monitoring.reinoldrojas.com.  IN  A 10.0.0.7
dns1.reinoldrojas.com. 	IN	A 	10.0.0.4	

; CNAME records
dns-1.reinoldrojas.com.	IN	CNAME	dns1.reinoldrojas.com.
jeeves.reinoldrojas.com.  IN  CNAME kvm1.reinoldrojas.com.
wiki.reinoldrojas.com.  IN  CNAME monitoring.reinoldrojas.com.
ansi.reinoldrojas.com.  IN  CNAME ansible.reinoldrojas.com.


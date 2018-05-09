$TTL	604800
@ 	IN	SOA	dns1.reinoldrojas.com. admin.reinoldrojas.com. (
		6	; Serial
	     604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800    ; Negative Cache TTL
	)
;
; name server - NS records
	IN 	NS 	dns1.reinoldrojas.com.

; name servers - A records
dns1.reinoldrojas.com. 	IN	A 	10.0.0.4	

; A records
dhcp.reinoldrojas.com.		IN	A 	10.0.0.2
ftp-1.reinoldrojas.com. 	IN	A	10.0.0.16
wiki.reinoldrojas.com.	 	IN	A	10.0.0.15
wordpress.reinoldrojas.com. 	IN	A 	10.0.0.17


; CNAME records
;dns-1.reinoldrojas.com.	IN	A	dns1.reinoldrojas.com

### Task 1
yum update -y
setenforce 0
systemctl stop firewalld
systemctl disable firewalld
#fqdn
echo "127.0.0.1 worker.stsiapan.hanchar" >> /etc/hosts
#sed -i 's/#ServerName www.example.com:80/ServerName worker.stsiapan.hanchar:80/' /etc/httpd/conf/httpd.conf
#enable mpm_worker & disable mpm_prefork
sed -i 's%LoadModule mpm_prefork_module modules/mod_mpm_prefork.so%#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so%' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's%#LoadModule mpm_worker_module modules/mod_mpm_worker.so%LoadModule mpm_worker_module modules/mod_mpm_worker.so%' /etc/httpd/conf.modules.d/00-mpm.conf
systemctl restart httpd
httpd -V | grep -i mpm
# set mpm_worker config

yum install -y epel-release
yum install -y htop

cat << EOF > /etc/httpd/conf.modules.d/10-worker.conf
<IfModule worker.c>
	ServerLimit 			10
	StartServers 			3
	MaxRequestWorkers 		50
	MinSpareThreads 		25
	MaxSpareThreads 		50
	ThreadsPerChild		 	5		
	MaxRequestsPerChild 	0	
</IfModule>
EOF

systemctl restart httpd
ab -c 700 -n 200000 -k worker.stsiapan.hanchar/
htop -u apache


#disable mpm_worker & enable mpm_prefork and configure
cat << EOF > /etc/httpd/conf.modules.d/10-prefork.conf
<IfModule mpm_prefork_module>
StartServers 5
MaxRequestWorkers 25
MinSpareServers 5
MaxSpareServers 10
MaxConnectionsPerChild 0
</IfModule>
EOF
sed -i 's%#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so%LoadModule mpm_prefork_module modules/mod_mpm_prefork.so%;s%LoadModule mpm_worker_module modules/mod_mpm_worker.so%#LoadModule mpm_worker_module modules/mod_mpm_worker.so%' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/127.0.0.1 worker.stsiapan.hanchar/127.0.0.1 prefork.stsiapan.hanchar/' /etc/hosts
#sed -i 's/ServerName worker.stsiapan.hanchar:80/ServerName prefork.stsiapan.hanchar:80/' /etc/httpd/conf/httpd.conf
systemctl restart httpd
httpd -V | grep MPM
ab -c 700 -n 200000 -k worker.stsiapan.hanchar/
htop -u apache

sed -i 's/ServerName worker.stsiapan.hanchar:80/#ServerName prefork.stsiapan.hanchar:80/' /etc/httpd/conf/httpd.conf

### Task 2

## Forward proxy
echo "127.0.0.1 forward.stsiapan.hanchar" >>/etc/hosts
sed -i '/Listen 80/a Listen 8080' /etc/httpd/conf/httpd.conf

cat << EOF > /etc/httpd/conf.d/forward_proxy.conf
<VirtualHost *:8080>
ProxyRequests On
ProxyVia On

<Proxy *>
      AuthType Basic
      AuthName "Authentication Required"
      AuthUserFile "/etc/httpd/conf/.passwd"
      Require valid-user
      Order allow,deny
      Allow from all
</Proxy>
EOF

# make user and password for proxy auth [user:password]
htpasswd -c /etc/httpd/conf/.passwd user

systemctl restart httpd

#windows hosts -> "IP-address Centos7(httpd)" "forward.stsiapan.hanchar"

## Reverse proxy
#needs to off forward_proxy.conf

echo "127.0.0.1 reverse.stsiapan.hanchar" >>/etc/hosts

cat << EOF > /etc/httpd/conf.d/reverse_proxy.conf
<VirtualHost *:80>
ProxyPreserveHost On
ProxyPass / http://mail.ru/
ProxyPassReverse / http://mail.ru/
</VirtualHost>
EOF

systemctl restart httpd



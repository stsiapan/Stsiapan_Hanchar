yum update -y

# install httpd
setenforce 0
yum install -y httpd
yum install -y nano

sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload

echo "<h2>Hello from httpd</h2>
<hr />
<p>Created by Name Surname</p>" > /var/www/html/index.html

systemctl start httpd
httpd -t
httpd -S
systemctl stop httpd

# install apache

yum -y install gcc
yum install -y wget

yum groupinstall "Development Tools"  -y
yum install expat-devel pcre pcre-devel openssl-devel -y

wget http://ftp.byfly.by/pub/apache.org//httpd/httpd-2.4.41.tar.gz
wget https://github.com/apache/httpd/archive/2.4.41.tar.gz
wget https://github.com/apache/apr/archive/1.7.0.tar.gz
wget https://github.com/apache/apr-util/archive/1.6.1.tar.gz

tar xzf httpd-2.4.41.tar.gz
tar xzf 1.7.0.tar.gz
tar xzf 1.6.1.tar.gz
 
mv apr-1.7.0 httpd-2.4.41/srclib/apr
mv apr-util-1.6.1 httpd-2.4.41/srclib/apr-util	
cd httpd-2.4.41
make
make install
 
./buildconf 
./configure --enable-ssl --enable-so --with-mpm=event --with-included-apr --prefix=/usr/local/apache2

/usr/local/apache2/bin/apachectl -k start
/usr/local/apache2/bin/apachectl -S
/usr/local/apache2/bin/apachectl -k stop

# <>
graceful signal causes the parent process to advise the children to exit after their current request (or to exit immediately if they're not serving anything). The parent re-reads its configuration files and re-opens its log files. As each child dies off the parent replaces it with a child from the new generation of the configuration, which begins serving new requests immediately.'
# <>


### task2 ###

mkdir /var/www/html/vhost
echo "<head>
 <title>www.stepan.by</title>
</head>

<body>
Working vhost
</body>      
       
</html>" > /var/www/html/vhost/index.html

chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

echo "<VirtualHost *:80>

  ServerName www.stsiapan.hanchar
  ServerAlias stsiapan.hanchar
  DocumentRoot /var/www/html/vhost
  ErrorLog /var/www/html/vhost/error.log
  CustomLog /var/www/html/vhost/access.log combined

</VirtualHost>" > /etc/httpd/conf.d/vhosts.conf

systemctl reload httpd

# resolve name
echo "127.0.0.1 www.stsiapan.hanchar
127.0.0.1 stsiapan.hanchar" >> /etc/hosts

# ping.html
echo "<h2>This is ping.html</h2>
<hr />
<p>Created by Stsiapan Hanchar</p>" > /var/www/html/vhost/ping.html

# enable redirect

nano /etc/httpd/conf.d/vhosts.conf -> 

</VirtualHost>%  RewriteEngine On
  RewriteRule ^/$ /index.html [R,L]
  RewriteRule ^/index.html /ping.html [R,L]
  RewriteRule ^/ping.html /ping.html [L]
  RewriteRule ^.* - [F]

</VirtualHost> 
#
systemctl restart httpd

## Task 3

yum install -y epel-release
yum install -y cronolog
#
nano /etc/httpd/conf.d/vhosts.conf ->

ErrorLog "| /usr/sbin/cronolog /var/www/html/vhost/error-SHanchar-%Y-%m-%d.log"
  CustomLog "| /usr/sbin/cronolog /var/www/html/vhost/access-SHanhar-%Y-%m-%d.log" combined
#

yum install -y tree

## Task 4

nano /etc/httpd/conf.d/vhosts.conf ->

 ErrorLog "|/usr/bin/logger -thttpd -plocal6.err"
 CustomLog "|/usr/bin/logger -thttpd -plocal6.notice" combined

curl -I www.stsiapan.hanchar

tail -n 5 /var/log/messages







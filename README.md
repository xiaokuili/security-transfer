# security-transfer
公网数据传输

## why
解决公网数据传输安全性问题， 两个nginx之间加密传输

## server启动
接收tsl数据， 并且转发到pg
```cd ./server && docker-compose up -d```

## client启动
读取pg, 发送tsl数据
```cd ./client && docker-compose up -d```

## 修改配置
### ./client/nginx.conf
```

user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
}

stream {

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        upstream remote{
            // 本地连到客户端地址
            server 192.168.200.58:443;
        }

        server {
            listen 5432 ;
            listen [::]:5432 ;

            proxy_pass remote;
            proxy_ssl_trusted_certificate /etc/nginx/ca.crt;
            proxy_ssl_verify on;
            proxy_ssl_server_name on;
            proxy_ssl_name hsmap.com;

            proxy_ssl on;
            proxy_ssl_certificate /etc/nginx/client.crt;
            proxy_ssl_certificate_key /etc/nginx/client.key;
            

            

        }
}

```
### ./server/nginx.conf
```
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
}
stream {

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        server {
                listen 443 ssl;
                proxy_pass 192.168.200.48:5432;   # 客户端连接到pg的地址

                ssl_certificate /etc/nginx/server.crt;
                ssl_certificate_key /etc/nginx/server.key;

                ssl_verify_client on;
                ssl_client_certificate /etc/nginx/ca.crt;
        }
}


```

ChangeLog 
- 适配区块链证书体系
- 国密


ChangeLog  2023-3-3
- nginx tsl转发
- 双端认证


## 端口转发
server端口转发修改docker-compose.yml
```
```- 8012:443```

client端口转发 nginx.conf
```
upstream remote{
            server 192.168.200.58:8012;
}
```
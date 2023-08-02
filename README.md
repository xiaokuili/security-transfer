![部署及服务器示例图](https://github.com/xiaokuili/security-transfer/assets/75962709/d8986ab9-794e-4853-96af-e93a118a0cee)# security-transfer

公网数据传输

## why

解决公网数据传输安全性问题， 两个nginx之间加密传输

## server启动

接收tsl数据， 并且转发到pg
``cd ./server && docker-compose up -d``

## client启动

读取pg, 发送tsl数据
``cd ./client && docker-compose up -d``

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

#### 新加客户端配置示例

添加如下代码块到nginx.conf的stream {...}

```
upstream remote1{
            // 本地连到客户端地址
            server 192.168.200.160:443;
        }

        server {
            listen 5432 ;
            listen [::]:5432 ;

            proxy_pass remote1;
            proxy_ssl_trusted_certificate /etc/nginx/ca.crt;
            proxy_ssl_verify on;
            proxy_ssl_server_name on;
            proxy_ssl_name hsmap.com;

            proxy_ssl on;
            proxy_ssl_certificate /etc/nginx/client.crt;
            proxy_ssl_certificate_key /etc/nginx/client.key;
        
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
- 8012:443
client端口转发 nginx.conf
```

upstream remote{
            server 192.168.200.58:8012;
}

```
## 查看端口是否开放
netstat -tunlp
```
### 设置证书有效时长
./gene_ca/gene.sh

```
生成证书的命令 (如 openssl req 和 openssl x509)加上 -days 365 
```

### 部署图
![image](https://github.com/xiaokuili/security-transfer/assets/75962709/c701a846-418e-420a-84a2-c6c17552ebc2)


### 配置文件修改后,启动服务

```
//启动 client 本地服务器使用 
make client-up
//启动 server 可连接目标数据库服务器使用
make server-up
//停止服务
make stop
```

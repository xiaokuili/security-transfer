#!/bin/bash
#DAY 是证书有效时长 以天为单位
DAY=$1
# 使用命令 "mkdir -p" 可以创建嵌套的目录，即使上级目录不存在
mkdir -p ./ca


rm -rf ./ca/*



# 生成 CA 根证书
openssl genrsa -out ./ca/ca.key 2048 
openssl req -new -x509 -key ./ca/ca.key -sha256 -subj "/CN=CA Root" -out ./ca/ca.crt -days $DAY
wait

# 生成客户端证书
openssl genrsa -out ./ca/client.key 2048 
openssl req -new -key ./ca/client.key -out ./ca/client.csr -subj "/CN=hsmap.com" -days $DAY
openssl x509 -req -in ./ca/client.csr -CA ./ca/ca.crt -CAkey ./ca/ca.key -CAcreateserial -out ./ca/client.crt -sha256 -days $DAY
wait

# 生成服务器证书
openssl genrsa -out ./ca/server.key 2048 
openssl req -new -key ./ca/server.key -out ./ca/server.csr -subj "/CN=hsmap.com" -days $DAY
openssl x509 -req -in ./ca/server.csr -CA ./ca/ca.crt -CAkey ./ca/ca.key -CAcreateserial -out ./ca/server.crt -sha256 -days $DAY
wait

# 删除临时文件
rm  ./ca/client.csr ./ca/server.csr

# 设置文件权限（可选）
chmod 600 ./ca/*.key
chmod 644 ./ca/*.crt

# 分发公钥
cp ./ca/*.crt ../client/
cp ./ca/*.crt ../server/
cp ./ca/*.crt ../root/

# 分发私钥
cp ./ca/client.key ../client/
cp ./ca/server.key ../server/
cp ./ca/ca.key ../root/


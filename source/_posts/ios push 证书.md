title: ios php push证书
tags: []
categories:
  - 工作笔记
author: kiean
date: 2017-01-18 14:12:00
---
# IOS PhP 证书生成

```
openssl pkcs12 -nocerts -out PushChatKey.pem -in apns-dev-cert.p12
```

```
openssl pkcs12 -clcerts -nokeys -out apns-dev-cert.pem -in apns-dev-cert.p12
```

```
cat PushChatKey.pem apns-dev-cert.pem > ck.pem
```
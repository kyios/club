---
title: HTTP Agreement
date: 2018-06-09 14:21:14
tags:
  - http
categories:
  - 网络
author: 奎宇

---
## HTTP协议详解

HTTP协议，即超文本传输协议(Hypertext transfer protocol)。是一种详细规定了浏览器和万维网(WWW = World Wide Web)服务器之间互相通信的规则，通过因特网传送万维网文档的数据传送协议。

HTTP是一个应用层协议，由请求和响应构成，是一个标准的客户端服务器模型。HTTP是一个**无状态的协议**。

- 所有的传输都是通过TCP/IP进行的。
- HTTP协议作为TCP/IP模型中应用层的协议
- HTTP协议通常承载于TCP协议之上，有时也承载于TLS或SSL协议层之上（https）

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/HTTP-Agreement/weblevel.png)
HTTP默认的端口号为80，HTTPS的端口号为443。

### 特点

> HTTP 永远是客户端发情请求，服务端回送响应。

- 支持客户/服务器模式。支持基本认证和安全认证。
- 简单快速：客户向服务器请求服务时，只需传送请求方法和路径。请求方法常用的有GET、HEAD、POST。每种方法规定了客户与服务器联系的类型不同。由于HTTP协议简单，使得HTTP服务器的程序规模小，因而通信速度很快。
- 灵活：HTTP允许传输任意类型的数据对象。正在传输的类型由Content-Type加以标记。
- HTTP 1.1使用持续连接：不必为每个web对象创建一个新的连接，一个连接可以传送多个对象，采用这种方式可以节省传输时间。
- 无状态：HTTP协议是无状态协议。无状态是指协议对于事务处理没有记忆能力。缺少状态意味着如果后续处理需要前面的信息，则它必须重传，这样可能导致每次连接传送的数据量增大。
<!-- more -->

### 无状态协议
协议的状态是指下一次传输可以“记住”这次传输信息的能力。
http是不会为了下一次连接而维护这次连接所传输的信息,为了保证服务器内存。
> 比如客户获得一张网页之后关闭浏览器，然后再一次启动浏览器，再登陆该网站，但是服务器并不知道客户关闭了一次浏览器

** 无状态和`Connection:keep-alive`区别 ** 
HTTP/1.1起，默认都开启了Keep-Alive，保持连接特性.

* 网页打开完成后，客户端和服务器之间用于传输HTTP数据的TCP连接不会关闭，如果客户端再次访问这个服务器上的网页，会继续使用这一条已经建立的连接。
* Keep-Alive不会永久保持连接，它有一个保持时间，可以在不同的服务器软件（如Apache）中设定这个时间。

### 工作流程

HTTP是基于传输层的TCP协议，而TCP是一个端到端的面向连接的协议。

**简要流程**
以下是 HTTP 请求/响应的步骤：

1、客户端连接到Web服务器
一个HTTP客户端，通常是浏览器，与Web服务器的HTTP端口（默认为80）建立一个TCP套接字连接。例如，http://www.oakcms.cn
2、发送HTTP请求
通过TCP套接字，客户端向Web服务器发送一个文本的请求报文，一个请求报文由请求行、请求头部、空行和请求数据4部分组成。
3、服务器接受请求并返回HTTP响应
Web服务器解析请求，定位请求资源。服务器将资源复本写到TCP套接字，由客户端读取。一个响应由状态行、响应头部、空行和响应数据4部分组成。
4、释放连接TCP连接
若connection 模式为close，则服务器主动关闭TCP连接，客户端被动关闭连接，释放TCP连接;若connection 模式为keepalive，则该连接会保持一段时间，在该时间内可以继续接收请求;
5、客户端解析内容


**建立TCP连接**

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/HTTP-Agreement/tcpConnectInfo.png)

户端浏览器与服务器的交互过程：
1、 No1：浏览器向服务器（发出连接请求。此为TCP三次握手第一步，此时从图中可以看出，为SYN，seq:X （x=0）；
2、 No2：服务器回应了浏览器的请求，并要求确认，此时为：SYN，ACK，此时seq：y（y为0），ACK：x+1（为1）。此为三次握手的第二步；
3、 No3：浏览器回应了服务器（115.239.210.36）的确认，连接成功。为：ACK，此时seq：x+1（为1），ACK：y+1（为1）。此为三次握手的第三步；
4、 No4：客户端发出HTTP请求；
5、 No5：服务器确认；
6、 No6：服务器发送数据；
7、 No7：客户端确认；

### 请求头域
#### URL 详情
URI一般由三部组成：
①协议(或称为服务方式)
②存有该资源的主机IP地址(有时也包括端口号)
③主机资源的具体地址。如目录和文件名等

#### HTTP之请求消息Request

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/HTTP-Agreement/webrequest.png)

```
GET /books HTTP/1.1
Host: www.wrox.com
User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6)
Gecko/20050225 Firefox/1.0.1
Connection: Keep-Alive

```

**请求行**
用来说明请求类型,要访问的资源以及所使用的HTTP版本.
GET说明请求类型为GET,`/books`为要访问的资源，该行的最后一部分说明使用的是HTTP1.1版本。

**请求头部**
紧接着请求行（即第一行）之后的部分，用来说明服务器要使用的附加信息
- HOST 将指出请求的域名或IP 地址。
- User-Agent,服务器端和客户端脚本都能访问它，它是浏览器类型检测逻辑的重要基础.该信息由你的浏览器来定义,并且在每个请求中自动发送

header | 解释 | 示例
--|--|---
Accept | 指定客户端能够接收的内容类型  | Accept: text/plain, text/html
Accept-Charset  | 浏览器可以接受的字符编码集。  | Accept-Charset: iso-8859-5
Accept-Encoding  | 指定浏览器可以支持的web服务器返回内容压缩编码类型。  | Accept-Encoding: compress, gzip
Accept-Language  | 浏览器可接受的语言  | Accept-Language: en,zh
Accept-Ranges  | 可以请求网页实体的一个或者多个子范围字段  | Accept-Ranges: bytes
Authorization  | HTTP授权的授权证书  | Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
Cache-Control  | 指定请求和响应遵循的缓存机制  | Cache-Control: no-cache
Connection  | 表示是否需要持久连接。（HTTP 1.1默认进行持久连接）  | Connection: close
Cookie  | HTTP请求发送时，会把保存在该请求域名下的所有cookie值一起发送给web服务器。  | Cookie: $Version=1; Skin=new;
Content-Length  | 请求的内容长度  | Content-Length: 348
Content-Type  | 请求的与实体对应的MIME信息  | Content-Type: application/x-www-form-urlencoded
Date  | 请求发送的日期和时间  | Date: Tue, 15 Nov 2010 08:12:31 GMT
Expect  | 请求的特定的服务器行为  | Expect: 100-continue
From  | 发出请求的用户的Email  | From: user@email.com
Host  | 指定请求的服务器的域名和端口号  | Host: www.zcmhi.com
If-Match  | 只有请求内容与实体相匹配才有效  | If-Match: “737060cd8c284d8af7ad3082f209582d”
If-Modified-Since  | 如果请求的部分在指定时间之后被修改则请求成功，未被修改则返回304代码  | If-Modified-Since: Sat, 29 Oct 2010 19:43:31 GMT
If-None-Match  | 如果内容未改变返回304代码，参数为服务器先前发送的Etag，与服务器回应的Etag比较判断是否改变  | If-None-Match: Referer“737060cd8c284d8af7ad3082f209582d”
If-Range  | 如果实体未改变，服务器发送客户端丢失的部分，否则发送整个实体。参数也为Etag  | If-Range: “737060cd8c284d8af7ad3082f209582d”
If-Unmodified-Since  | 只在实体在指定时间之后未被修改才请求成功  | If-Unmodified-Since: Sat, 29 Oct 2010 19:43:31 GMT
Max-Forwards  | 限制信息通过代理和网关传送的时间  | Max-Forwards: 10
Pragma  | 用来包含实现特定的指令  | Pragma: no-cache
Proxy-Authorization  | 连接到代理的授权证书  | Proxy-Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
Range  | 只请求实体的一部分，指定范围  | Range: bytes=500-999
Referer  | 先前网页的地址，当前请求网页紧随其后,即来路  | Referer: http://www.zcmhi.com/archives/71.html
TE  | 客户端愿意接受的传输编码，并通知服务器接受接受尾加头信息  | TE: trailers,deflate;q=0.5
Upgrade  | 向服务器指定某种传输协议以便服务器进行转换（如果支持）  | Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11
User-Agent  | User-Agent的内容包含发出请求的用户信息  | User-Agent: Mozilla/5.0 (Linux; X11)
Via  | 通知中间网关或代理服务器地址，通信协议  | Via: 1.0 fred, 1.1 nowhere.com (Apache/1.1)
Warning  | 关于消息实体的警告信息  | Warn: 199 Miscellaneous warning

通用的信息性首部:
Connection,Date,MIME-Version


**空行**
请求头部后面的空行是必须的，即使第四部分的请求数据为空，也必须有空行。

**主体**
请求数据也叫主体，可以添加任意的其他数据。


```
POST / HTTP1.1
Host:www.wrox.com
User-Agent:Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)
Content-Type:application/x-www-form-urlencoded
Content-Length:40
Connection: Keep-Alive

name=Professional%20Ajax&publisher=Wiley
```

第一部分：请求行，第一行明了是post请求，以及http1.1版本。
第二部分：请求头部，第二行至第六行。
第三部分：空行，第七行的空行。
第四部分：请求数据，第八行。

#### 请求方法
HTTP/1.1协议中共定义了八种方法（有时也叫“动作”）来表明Request-URI指定的资源的不同操作方式：

* OPTIONS- 返回服务器针对特定资源所支持的HTTP请求方法。也可以利用向Web服务器发送'*' 的请求来测试服务器的功能性。
* HEAD- 向服务器索要与GET请求相一致的响应，只不过响应体将不会被返回。这一方法可以在不必传输整个响应内容的情况下，就可以获取包含在响应消息头中的元信息。该方法常用于测试超链接的有效性，是否可以访问，以及最近是否更新。
* GET- 向特定的资源发出请求。注意：GET方法不应当被用于产生“副作用”的操作中，例如在web app.中。其中一个原因是GET可能会被网络蜘蛛等随意访问。
* POST- 向指定资源提交数据进行处理请求（例如提交表单或者上传文件）。数据被包含在请求体中。POST请求可能会导致新的资源的建立和/或已有资源的修改。
* PUT- 向指定资源位置上传其最新内容。
* DELETE- 请求服务器删除Request-URI所标识的资源。
* TRACE- 回显服务器收到的请求，主要用于测试或诊断。
* CONNECT- HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器。
* PATCH- 用来将局部修改应用于某一资源，添加于规范RFC5789。

### 响应消息

客户端向服务器发送一个请求，服务器以一个状态行作为响应.
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/HTTP-Agreement/httpresponse.png)


响应的内容包括
- 消息协议的版本
- 成功或者错误编码
- 服务器信息
- 实体元信息
- 实体内容

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/HTTP-Agreement/20190109073058958.png)

**状态行**
由HTTP协议版本号， 状态码， 状态消息 三部分组成。
（HTTP/1.1）表明HTTP版本为1.1版本，状态码为200，状态消息为（ok）
**消息报头**
用来说明客户端要使用的一些附加信息.
第二行和第三行为消息报头.
Date:生成响应的日期和时间；
Content-Type:指定了MIME类型的HTML(text/html),编码类型是UTF-8

**空行**
消息报头后面的空行是必须的

**响应正文**
空行后面的部分为响应正文。

**HTTP之状态码**
状态代码有三位数字组成，第一个数字定义了响应的类别，共分五种类别:
- 1xx：指示信息--表示请求已接收，继续处理
- 2xx：成功--表示请求已被成功接收、理解、接受
- 3xx：重定向--要完成请求必须进行更进一步的操作
- 4xx：客户端错误--请求有语法错误或请求无法实现
- 5xx：服务器端错误--服务器未能实现合法的请求

```
200 OK                        //客户端请求成功
400 Bad Request               //客户端请求有语法错误，不能被服务器所理解
401 Unauthorized              //请求未经授权，这个状态代码必须和WWW-Authenticate报头域一起使用 
403 Forbidden                 //服务器收到请求，但是拒绝提供服务
404 Not Found                 //请求资源不存在，eg：输入了错误的URL
500 Internal Server Error     //服务器发生不可预期的错误
503 Server Unavailable        //服务器当前不能处理客户端的请求，一段时间后可能恢复正常
```

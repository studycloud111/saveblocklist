# 负载  -   复用   -   

- 脚本1：
```ssh
wget --no-check-certificate -O date.sh "https://raw.githubusercontent.com/studycloud111/saveblocklist/main/ate.sh" && chmod +x ate.sh && ./ate.sh
```

```ssh
wget --no-check-certificate -O file.sh "https://raw.githubusercontent.com/studycloud111/saveblocklist/main/file.sh" && chmod +x file.sh && ./file.sh
```

- ip 变化， 自动重启
```ssh
wget --no-check-certificate -O check_ddns.sh "https://raw.githubusercontent.com/studycloud111/saveblocklist/main/check_ddns.sh" && chmod +x check_ddns.sh && ./check_ddns.sh
```

- docker nginx
```ssh
docker run -d --name tengine -p 80:80 -p 443:443 -v /usr/local:/usr/local spcloud12/tengine-3.0.0:latest
```

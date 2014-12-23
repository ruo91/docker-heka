Dockerfile - Mozllia Heka
=========================
#### Build
```
root@ruo91:~# git clone https://github.com/ruo91/docker-heka /opt/docker-heka
root@ruo91:~# docker build --rm -t heka /opt/docker-heka
```

#### Run
```
root@ruo91:~# docker run -d --name="heka" -h "heka" -v /var/log:/log heka
```

#### SSH
```
root@ruo91:~# ssh `docker inspect -f '{{ .NetworkSettings.IPAddress }}' heka`
```


Mozilla Heka
![Mozilla Heka][1]


Thanks. :-)

  [1]: http://cdn.yongbok.net/ruo91/img/heka/heka.png

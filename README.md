# 项目简介
## 这是酷狗音乐和酷狗繁星网站的发版工具，这应该是第四版。它也是酷狗运维部门的发版工具的始祖，现在运维部使用的发版工具功能还没我们这个工具强大。
## 目前这个工具已经发展到第五个版本了。现在繁星还是在使用这个工具，而不是运维部的发版工具。这里放的是第四版。里面涉及的网站我自测已经迁移完毕。
## 最凶残的是单个网站一天发布了31次版本
## 这个项目发在这里做个留念。有需要的人可以拿去学习或者参考。欢迎留言交流 , 这个项目在第四个版本有另外一个同事忠信加入，终于不是孤军奋战了T.T
## 联系我
### http://www.mmfei.com
### wlfkongl@163.com


# 此项目历史

### 2012年8月 ， 酷狗繁星网建队成功。 当时有10人不到（大飞，小蔡，少勇，小白，大桥，啊统，欢哥），在勤天大厦10106拼死赶工。这个还没建队没人没需求就已经确定上线时间的项目，2月不到，在9月20日上线。现在繁星网核心功能都还很多是在那时候建立的。

### 由于当时酷狗还是win系列的，第一个linux运维跟我是当天入职，it部门确实是一个一穷二白的现状。

## 第一版，基于svn的自动化发版工具
### 我们项目因为是创业项目，属于没爹没娘也没奶的情况。啥都要自己撸，所以就赶工两天搞了个上线的自动化发版工具，基于svn的。 其实就是 命令行敲  `./fx.svn.sh 开始版本 结束版本 是否测试服` ，就代码就直接自动化上线完毕，完成内容就是从svn export代码出来，打包成tar，然后upload到2台服务器，再服务器上解压就结束了。

随着项目推进，最后演化成：svn -> tar -> (n * server  + unzip ) & (crontab server & reload crontab) -> send email to everyone

## 第二版 ，跳板机

### 引入跳板机
```
svn -> tar  -> relay server -> ( unzip -> rsync -> n * server ) & (crontab server & reload crontab) -> send email to everyone
```

## 可配置发版项目
### 增加根据模板配置功能
由于项目发展很快，当时这个由我个人维护的项目已经要搞10个站点*4 套发版配置，人力实在是疲于奔命。所以改进了下
```
1. 增加读取配置功能
2. 增加密码功能（多项目）
3. 完善阶段性提醒（交互更友好）
```
发版流程照旧
```
svn -> tar  -> relay server -> unzip -> rsync server -> ( rsync -> n * server ) & (crontab server & reload crontab) -> send email to everyone
```

## 项目支持git和svn
### 增加git项目的支持
```
1. 增加读取配置功能
2. 增加密码功能（多项目）
3. 完善阶段性提醒（交互更友好）
4. 支持发版记录
5. 支持错误密码记录
6. 支持输入发版邮件内容
8. 支持选项目发版
9. 使用rsyncd服务器做同步服务
```
发版流程照旧
```
svn -> tar  -> relay server -> unzip -> rsync server -> ( rsync -> n * server ) & (crontab server & reload crontab) -> send email to everyone
```
## 项目支持自动化打包部署安装，初始化环境。【这个没放到github】，属于现在运行版本，保留
### 
```
1. 一键部署
2. 一键发版
3. 自定义安装
4. 自己搭建安装包源（其实是使用ftp存档安装包,T.T）
```


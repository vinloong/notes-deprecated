# 服务端部署

```yaml
version: "3" 
services:
  sonarqube:
    image: sonarqube:lts-community
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://10.8.30.156:5432/sonarqube
      SONAR_JDBC_USERNAME: sonarqubeAdmin
      SONAR_JDBC_PASSWORD: sonarqubeAdmin_123
      SONAR_JDBC_MAXACTIVE: "100"
      SONAR_JDBC_MAXIDLE: "10"
      SONAR_JDBC_MINIDLE: "5"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9000:9000"
volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
```

部署成功：
![](http://resources.lingwenlong.com/note-img/20210609140531.png)

# 体验
在服务端新增项目：
![](http://resources.lingwenlong.com/note-img/20210609141402.png)

![](http://resources.lingwenlong.com/note-img/20210609141707.png)

这个项目是一个maven 构建的项目，项目是scala 的，

按照提示执行 `maven`命令：
```
mvn sonar:sonar \
  -Dsonar.projectKey=et \
  -Dsonar.host.url=http://10.8.30.158:9000 \
  -Dsonar.login=d3ce7e00c8fcc9adc3b85b97d3c1005766cb2498
```

使用 `idea ide` 的 可以在安装插件，
> `File` ---> `Settings...` ---> `Plugins`
> 查找 `sonar` 可以找到插件，安装即可

安装 [sonarscanner](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)

执行后，代码扫描完成，
![](http://resources.lingwenlong.com/note-img/20210609143305.png)

可以看到总览。

# Jenkins 集成
Jenkins 安装 插件 `SonarQube Scanner for Jenkins`

在 Jenkins 添加 凭据：
![](http://resources.lingwenlong.com/note-img/20210609143839.png)


在 系统管理 ---> 系统配置中 ---> `SonarQube servers`
![](http://resources.lingwenlong.com/note-img/20210609144051.png)

在项目构建配置中添加
![](http://resources.lingwenlong.com/note-img/20210609144231.png)

![](http://resources.lingwenlong.com/note-img/20210609144309.png)

构建成功完成后：
![](http://resources.lingwenlong.com/note-img/20210609144522.png)

点击上图框的图标，就可以看到 静态扫描的总览了
![](http://resources.lingwenlong.com/note-img/20210609144655.png)


# 代码规则
`sonarQube` 支持自定义代码规则
下面以 go 语言配置为例：
![](http://resources.lingwenlong.com/note-img/20210609145338.png)

内置的规则不能直接修改，复制内置的规则模板：
![](http://resources.lingwenlong.com/note-img/20210609145408.png)

![](http://resources.lingwenlong.com/note-img/20210609145525.png)

可以选择 启用和禁用相关规则：
![](http://resources.lingwenlong.com/note-img/20210609145822.png)

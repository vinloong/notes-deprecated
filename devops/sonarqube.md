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
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191033085.png)

# 体验
在服务端新增项目：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191034303.png)

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191034295.png)

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
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191034312.png)

可以看到总览。

# Jenkins 集成
Jenkins 安装 插件 `SonarQube Scanner for Jenkins`

在 Jenkins 添加 凭据：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191034960.png)


在 系统管理 ---> 系统配置中 ---> `SonarQube servers`
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191035875.png)

在项目构建配置中添加
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191035205.png)

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191035162.png)

构建成功完成后：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191035170.png)

点击上图框的图标，就可以看到 静态扫描的总览了
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191036782.png)


# 代码规则
`sonarQube` 支持自定义代码规则
下面以 go 语言配置为例：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191036662.png)

内置的规则不能直接修改，复制内置的规则模板：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191036667.png)

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191036865.png)

可以选择 启用和禁用相关规则：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191037091.png)

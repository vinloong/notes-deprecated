# 安装

```shell
# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb\_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql

# 安装完毕后自动创建了系统和数据库的postgres用户
# 初始默认数据目录/var/lib/postgresql/9.6/main. 
# 配置文件目录/etc/postgresql/9.6/main.
```

# 配置

```
# 备份配置文件
cp postgresql.conf postgresql.conf.bak
cp pg_hba.conf pg_hba.conf.bak

# 修改 postgresql.conf
vi postgresql.conf
# listen_addresses = '*'


# 修改 pg_hba.conf
vi pg_hba.conf

# Database administrative login by Unix domain socket
local   all             postgres                                md5
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host   all   all   0.0.0.0/0   md5
```


```shell
service postgresql restart  # 重启服务
service postgresql stop     # 停止服务
service postgresql start    # 启动服务
```

# psql 使用

```shell
# 远程连接数据库
psql -h 127.0.0.1 -p 5432 -U dbuser -d exampledb

# 显示数据库版本
psql -V [or -version]

```

 **控制台命令** :
> `\h`：查看SQL命令的解释，比如\h select。
> `\?`：查看psql命令列表。
> `\l`：列出所有数据库。
> `\c [database_name]`：连接其他数据库。
> `\d`：列出当前数据库的所有表格。
> `\d [table_name]`：列出某一张表格的结构。
> `\dn`: 显示所有的schema
> `\dp`: 显示表的权限分配情况
> `\du`：列出所有用户。
> `\e`：打开文本编辑器。
> `\conninfo`：列出当前数据库和连接的信息。
> `\password`: 设置密码
> `\x`: 已列的形式展示 （当不想列展示时，再次`\x`即可)


```shell

# 创建用户
create user "FashionAdmin" with password 'Fas123_';

# 创建数据库
# create database imsdb [owner rcb]
create database "AnxinCloud" owner "FashionAdmin";

# 赋予用户数据库权限
GRANT ALL PRIVILEGES ON DATABASE exampledb TO dbuser;

# 把用户角色role1 对当前数据库的 权限给用户角色 role2
grant role1 to role2; 

# 修改数据库所有者
alter database imsdb owner to rcb

# 创建新表 
CREATE TABLE user_tbl(name VARCHAR(20), signup_date DATE);

# 插入数据 
INSERT INTO user_tbl(name, signup_date) VALUES('张三', '2013-12-22');

# 选择记录 
SELECT * FROM user_tbl;

# 更新数据 
UPDATE user_tbl set name = '李四' WHERE name = '张三';

# 删除记录 
DELETE FROM user_tbl WHERE name = '李四' ;

# 添加栏位 
ALTER TABLE user_tbl ADD email VARCHAR(40);

# 更新结构 
ALTER TABLE user_tbl ALTER COLUMN signup_date SET NOT NULL;

# 更名栏位 
ALTER TABLE user_tbl RENAME COLUMN signup_date TO signup;

# 删除栏位 
ALTER TABLE user_tbl DROP COLUMN email;

# 表格更名 
ALTER TABLE user_tbl RENAME TO backup_tbl;

# 删除表格 
DROP TABLE IF EXISTS backup_tbl;

# 删除数据库
DROP DATABASE dataBaseName; 

# 删除用户
drop role userRole; 

# 查询状态
select * from pg_stat_activity where datname ='DBName';

# kill 状态为 'Lock' 的进程
select pg_terminate_backend(pid) from select pid from pg_stat_activity where datname ='DBName' and wait_event_type = 'Lock';

# 显示当前的模式
show search_path

# 更改模式
set search_path to myschema

# 显示数据库版本
show server_version;
select version();

```


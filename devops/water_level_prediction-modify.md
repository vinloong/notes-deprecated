
# 看水位预测代码
我们拿到行业服务科发来的 python 脚本
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191113437.png)
我们是不能直接用的
有几个问题
1. 模型是用测点名区分的并且还使用了大量使用了中文
      为了防止一些编码上的问题或其他一些不必要的问题这里需要修改为使用测点id
   ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191113703.png)
   ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191113628.png)
   ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191113226.png)
2.  平台api 和 天气接口是写死的，平台api token 也是写死的
     
    ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191114073.png)
    ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191114754.png)
3.  多处读取配置文件
    ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191114684.png)
	![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191114023.png)
	![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191115621.png)
	![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191115786.png)
5.  数据存储需要改为 ES
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191115571.png)

另外 我们部署环境是k8s ，需要自己编写`Dockerfile` 来构建镜像

# 开始修改代码
1. 
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191115706.png)
把每个模型文件夹命名改为测点id,并修改相关引用代码，
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191117062.png)

配置文件和相关代码修改：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191117839.png)
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191117701.png)
10水位测点修改：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191117416.png)

2. 把天气和anxinyun平台 api 改为读取配置
    ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191118725.png)
3.  配置管理我们单独写一个文件，具备从配置文件和环境变量获取参数
    ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191118383.png)
    在每个使用参数的地方添加引用 `config` ，
	> 这里说下 `ConfigParser` 这个配置管理用的工具类，会把读取的配置存到对象实例，没必要每次都去读配置文件
4.  数据存到ES ,会用到 `elasticsearch6`
     ES 保存也很简单：
   ```python
   es = Elasticsearch(hosts=config.ES_REST_NODES.split(','))
   for index, value in enumerate(score):  
    data['forecast_entire'].append({  
        "forecast_time": '{}:00:00'.format((pre_now + timedelta(hours=index)).strftime('%Y-%m-%d %H')),  
        "value": float('%.4f' % ((float(value) - param) / 1000))
    })
	 
   ```
   可以看到上面对数据结果做了简单计算和精度处理。
   从数据库读取参数：
   ```python
   class PostgresDbHelper(object):  
    def __init__(self):  
        self._logger = logging.getLogger('PostgresDbHelper')  
        self._connection = psycopg2.connect(  
            user=config.DB_ANXINCLOUD_USER,  
            password=config.DB_ANXINCLOUD_PASSWD,  
            host=config.DB_ANXINCLOUD_HOST,  
            port=config.DB_ANXINCLOUD_PORT,  
            database=config.DB_ANXINCLOUD_NAME  
         )  
  
    def get_formal_params(self, sids):  
        try:  
            cursor = self._connection.cursor()  
            str_ids = ','.join('%s' % id for id in sids)  
            query = "SELECT sensor,params from t_device_sensor where sensor in ({0});".format(str_ids)  
            cursor.execute(query)  
            records = dict((record[0], float(record[1].get('DAQ0', 0))) for record in cursor.fetchall())  
            return records  
        except Exception as ex:  
            self._logger.warning("select formula params error", ex)  
        finally:  
            self._connection.commit()
   ```
5.  编写 `Dockerfile`
    ```Dockerfile
	FROM repository.anxinyun.cn/base-images/python-slim:9.21-05-25  
  
    WORKDIR /apps  
  
    COPY . .  
  
    RUN chmod u+x ./start.sh  
  
    CMD ["./start.sh" ]
	```
	
	上面基础镜像是定做的，因为网络环境不是很稳定，直接把虚拟环境和依赖打到基础镜像里了.
	
et-flink 代码走查

1. 流、连接等资源最好是添加异常捕捉，资源使用完成后关闭：

```
comm_utils/src/main/java/comm/utils/storage/HdfsHelper.java  				L98 
comm_utils/src/main/java/comm/utils/storage/HdfsHelperExtra.java  			L72
et_storage_hdfs/src/main/java/com/fs/Es2Hdfs.java							L214, L215, L272, L273
et_storage_hdfs/src/main/java/com/fs/es2hdfs/tools/HdfsHelper.java			L140, L179, L199
et_upload/src/main/java/wsdl/qingdao_kancha/DataPutter.java					L47, L150
et_upload/src/main/java/wsdl/sichuan/jdbc/SQLUtils.java						L131, L152, L198, L242, L259, L273, L286, L303, L340
```



```java
BufferedReader br = new BufferedReader(new InputStreamReader(is, EncodeName));
Connection conn = DriverManager.getConnection(propCfg.getProperty("db.url"), props);
Statement stmt = conn.createStatement();
FileWriter fw = new FileWriter(nf);
PreparedStatement pstmt = conn.prepareStatement(sql);
```

示例：

```java

private void doSomething() {
  OutputStream stream = null;
  try {
    for (String property : propertyList) {
      stream = new FileOutputStream("myfile.txt"); 
      // ...
    }
  } catch (Exception e) {
    // ...
  } finally {
    stream.close();  
  }
}
```


2. finally 块 不要再抛出异常

```
comm_utils/src/main/java/comm/utils/storage/HdfsHelper.java					L393
```



```java
finally {
            throw deserializationContext.mappingException(getValueClass());
}
```



3. arrary 转字符串，不能直接 `toString`

```
et_storage_hdfs/src/main/java/com/fs/Es2Hdfs.java				L1000, L1087
```

```java
 logger.info("   Invalid headers:" + factor_names.toArray().toString() + "!");
```

  

4. 声明一个变量取代多处引用的字符串

```
comm_utils/src/main/scala/comm/utils/ConfigHelper.scala 
config_center/src/main/scala/com/free_sun/config/HttpHelper.scala
```

```
"redis.guava.expireTime" 									7次
"redis.guava.expireTime.long"								3次
""Content-Type"												3次

```




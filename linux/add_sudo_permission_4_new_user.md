```bash
# 
usermod -aG sudo username

一种是修改/etc/sudoers文件，增加一行
username ALL=(ALL) ALL

一种是修改/etc/passwd 找到自己的用户一行吧里面的用户id改成0
```


# 列编辑

## 方式 一

- Shift+鼠标右键
- 鼠标中键

 评论：  个人觉得对右键和中键不太习惯配合键盘一起使用

## 方式 二

   sublime  对 列编辑模式 Key  binding设置如下：

   路径：Preferences→Key Bindings  

```json
   { "keys": ["ctrl+alt+up"], "command": "select_lines", "args": {"forward": false} },
   { "keys": ["ctrl+alt+down"], "command": "select_lines", "args": {"forward": true} },
```

  但ctrl+alt+up/down 和windows的快捷键设置冲突，我们可以自定义上述设置

​     路径：Preferences→Key Bindings – User

```json
1 [    { "keys": ["alt+up"], "command": "select_lines", "args": {"forward": false} },
2     { "keys": ["alt+down"], "command": "select_lines", "args": {"forward": true} },
3 ]    
```


# Lutra - 使用Ponylang编写的一个简易CLI SSH管理器 🐴 

## 安装指南

Arch 用户可以直接从AUR安装。假设你使用的是`yay`，则可以

`yay -S lutra # 假设使用yay作为包管理器, yaourt等同理`

## 从源码编译安装

### 依赖

编译该repo需要 `ponyc`。如果你还不知道**Ponylang/ponyc**是什么，看这里[ponyc](https://github.com/ponylang/ponyc).

### 编译&安装

在repo主目录下运行 `make && sudo make install` 来安装 `lutra`，默认安装路径是 `/usr/bin/lutra`。

## 使用方法

程序会默认加载路径配置文件 `${HOME}/.config/lutra/lutra.conf`，如果文件不存在将自动生成一个空配置

### 添加一个节点

`lutra -a NAME HOST [-p PORT] [-k SSH_KEY_FILE]`

### 连接到一个节点

`lutra NAME`

### 删除一个节点

`lutra -d NAME`

### 将一个节点设置为默认节点

`lutra -u test -s`
设置完之后， 运行lutra将默认连接该节点
`lutra # 将连接到名为test的节点！`


### 参数说明

**命令格式: lutra [options] [node] [dest]**

#### 参数:

	-i, --identify          指定连接时使用的用户名
	
	-l, --list             	列出所有节点
	
	-h, --help              打印帮助
	
	-a, --add               添加一个节点
	
	-s, --default=false    	将节点设为默认连接
	
	-f, --apply           	使用一个配置文件
	
	-d, --delete            删除一个节点
	
	-k, --key               指定该连接使用的SSH_KEY
	
	-u, --update            更新已保存的节点信息
	
	-p, --port=22           连接端口，默认为22
	
	Args:
   		node    节点名
   		dest    地址

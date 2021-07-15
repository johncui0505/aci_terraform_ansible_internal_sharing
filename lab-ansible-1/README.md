# Ansible Lab #1 - Ansible 基本用法

<br><br>

## Lab Step  

1. 查看 Inventory 文件内容。通过 Ping 命令来查看和各个 host 之间的联通性。

- hosts
```
[all]
20.194.42.125
20.194.31.201
20.194.41.201

[group1]
20.194.42.125
20.194.31.201

[group2]
20.194.41.201

```
- 执行以下命令并查看结果。

```
ansible -i hosts -u iacuser all -m ping

ansible -i hosts -u iacuser group1 -m ping

ansible -i hosts -u iacuser group2 -m ping
```

<br><br>

2. 通过 Command 模块和 Shell 模块对远程的服务器进行命令下发。

```
ansible -i hosts -u iacuser all -m command -a "free -m"

ansible -i hosts -u iacuser all -m shell -a "free -m | grep ^Swap:"

ansible -i hosts -u iacuser all -a 'netstat -nr'
```
- command 模块和 shell 模块几乎提供相同的功能，但是如果想使用环境变量、'>'、 '<'、 '|'、 ';'、 '&'，那么只能使用 shell 模块。

<br><br>

3. 通过 apt 模块，在 ubuntu 服务器中安装相关 package。
```
ansible -i hosts -u iacuser all -m apt -a "update_cache=yes" -b

ansible -i hosts -u iacuser all -m apt -a "name=nginx state=present" -b

ansible -i hosts -u iacuser all -m command -a "systemctl status nginx" -b

ansible -i hosts -u iacuser all -m command -a "curl localhost"
```

<br><br>

4. 通过 setup 模块，查看 ansible 查询到的服务器的信息。 
```
ansible -i hosts -u iacuser all -m setup
```

<br><br>

5. 通过 ansible playbook 命令执行大多数的操作。 
```
ansible-playbook -i hosts main.yml 
```

<br><br>

6. 通过 ansible-doc 命令查看模块的使用方法。
```
ansible-doc file
```

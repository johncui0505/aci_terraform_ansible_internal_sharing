# Ansible Lab #1 - Ansible 기본 사용법

<br><br>

## Lab 진행 순서  

1. 인벤토리 파일(hosts)의 내용을 살펴봅니다. 그리고나서 ping 모듈을 이용하여 각 호스트의 접속가능여부를 확인합니다.

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
- 다음 명령을 실행해봅니다.

```
ansible -i hosts -u iacuser all -m ping

ansible -i hosts -u iacuser group1 -m ping

ansible -i hosts -u iacuser group2 -m ping
```

<br><br>

2. Command 모듈과 Shell 모듈을 이용하여 리모트 서버에서 명령을 실행합니다.

```
ansible -i hosts -u iacuser all -m command -a "free -m"

ansible -i hosts -u iacuser all -m shell -a "free -m | grep ^Swap:"

ansible -i hosts -u iacuser all -a 'netstat -nr'
```
- command와 shell은 거의 유사한 기능을 제공하지만, 환경변수, '>', '<', '|', ';', '&' 을 사용하려면 shell을 이용합니다.

<br><br>

3. apt 모듈을 이용하여 ubuntu 서버에 패키지를 설치합니다.
```
ansible -i hosts -u iacuser all -m apt -a "update_cache=yes" -b

ansible -i hosts -u iacuser all -m apt -a "name=nginx state=present" -b

ansible -i hosts -u iacuser all -m command -a "systemctl status nginx" -b

ansible -i hosts -u iacuser all -m command -a "curl localhost"
```

<br><br>

4. setup 모듈을 이용하여, ansible이 수집한 호스트의 정보를 확인합니다. 
```
ansible -i hosts -u iacuser all -m setup
```

<br><br>

5. ansible playbook을 이용하여, 다수의 작업을 실행합니다. 
```
ansible-playbook -i hosts main.yml 
```

<br><br>

6. ansible-doc 명령을 이용하여 모듈의 사용법을 확인합니다.
```
ansible-doc file
```
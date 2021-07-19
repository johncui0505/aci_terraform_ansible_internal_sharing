# Ansible Lab #5 - ACI 健康分数传送到 Webex 

<br><br>

## Lab 步骤 

<br>

1. 查看 Playbook (main.yml) 内容。

```yaml
- hosts: aci
  connection: local
  gather_facts: no
  collections:
  - cisco.aci

  roles:
  - monitor_health
  - call_webex
```
- 通过 Role，把收集数据和传送数据的任务分离开。

<br><br>

2. 查看 roles/monitor_health/tasks/main.yml 文件内容。

```yaml
- name: "收集 System 健康分数数据"
  aci_rest:
    ...
    path: /api/mo/topology/health.json
    method: get
  register: health_system

- name: "收集 Topology 健康分数数据"
  aci_rest:
    ...
    path: /api/node/class/topSystem.json?rsp-subtree-include=health,required&rsp-subtree-filter=le(healthInst.cur,"{{ item.score }}")
    method: get
  with_items: 
    - score: 100
  register: health_topology

- name: "收集各个 Tenant 的健康分数"
  aci_rest:
    ...
    path: /api/node/class/fvTenant.json?rsp-subtree-include=health,required&rsp-subtree-filter=le(healthInst.cur,"{{ item.score }}")
    method: get
  with_items: 
    - score: 100
  register: health_tenant
```
- 收集 System，Topology, Tenant 健康分数。
- 对于 Topology 和 Tenant 健康分数，只收集低于100分的数据。 

<br>

```yaml
- name: "把 System/Topology/Tenant 健康分数存储为 JSON 文件"
  copy:
    content: "{{ item.content | to_nice_json}}"
    dest:    "{{ item.dest }}"
  no_log: yes
  loop:
    - content: "{{ health_system }}"
      dest:    "roles/monitor_health/files/health_system.json"
    - content: "{{ health_topology }}"
      dest:    "roles/monitor_health/files/health_topology.json"
    - content: "{{ health_tenant }}"
      dest:    "roles/monitor_health/files/health_tenant.json"

- name: "执行判断是否要传送消息的脚本（Python）"
  script: check.py
  register: check_result

- name: "把收集的信息以 Webex 接收的文件格式(Markdown)转换"
  template: 
    src:  "template/health_report.j2"
    dest: "roles/call_webex/files/health_report.md"
  when: check_result.stdout | bool
```
- 把各个健康分数数据以 JSON 文件存储。
- 通过 check.py 脚本，读取 JSON 文件以后，判断是否要传送。 
- 把要传送的数据，以 Webex 要接收的格式进行转换。

<br><br>

3. 查看 roles/call_webex/tasks/main.yml 文件内容。
```yaml
- name: "查看是否有要传送数据的文件"
  stat: path="roles/call_webex/files/health_report.md"
  register: file_check

- name: "读取文件内容"
  debug: msg="{{lookup('file', 'health_report.md') }}"
  register:   health_tenant_message
  when: file_check.stat.exists
  
- name: "向 Webex 发送信息" 
  cisco_spark:
    recipient_type:   roomId
    recipient_id:     "{{ roomID }}"
    message_type:     markdown
    personal_token:   "{{ bot_token }}"
    message:          "{{ health_tenant_message.msg }}"
  when: file_check.stat.exists
```
- 查看是否有要传送信息的文件。
- 如果有，读取文件内容，并发送给Webex。

<br>

```yaml
- name: "删除已发送数据的文件"
  file:
    path: roles/call_webex/files/health_report.md
    state: absent
```
- 把已经发送数据的文件进行删除。

<br><br>

4. 执行 Playbook，查看结果。
```
ansible-playbook -i hosts main.yml
```

<br><br>

5. 在 roles/monitor_health/tasks/main.yml 文件中修改基准分数值。
```yaml
- name: "收集 Topology 健康分数数据"
  aci_rest:
    ...
    path: /api/node/class/topSystem.json?rsp-subtree-include=health,required&rsp-subtree-filter=le(healthInst.cur,"{{ item.score }}")
    method: get
  with_items: 
    - score: 100
  register: health_topology

- name: "收集各个 Tenant 的健康分数"
  aci_rest:
    ...
    path: /api/node/class/fvTenant.json?rsp-subtree-include=health,required&rsp-subtree-filter=le(healthInst.cur,"{{ item.score }}")
    method: get
  with_items: 
    - score: 100
  register: health_tenant
```
- 把 score: 100 修改为更小的值，再执行 Playbook。 

<br><br>

6. 执行 Playbook 并查看结果。
```
ansible-playbook -i hosts main.yml
```

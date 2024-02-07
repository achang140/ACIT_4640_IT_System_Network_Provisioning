# ACIT 4640 - Lab 5 

## Group Members
* Amanda Chang 
* Dennis Phan 
* ByeongJu (Jace) Kang 
* Simon Freeman

## Questions 

1. **Write an ad hoc command that will display the kernel version of the "db" servers. (hint `uname`).**

``` 
ansible db -m shell -a "uname -v" 
```

2. **Write an ad hoc command that will install nginx on the web servers. (hint Ansible has a number of package modules, including an apt module)**

```	
ansible web -m apt -a “name-nginx state=present” -b
```

3. **Create a 'file' directory and add the HTML document below as 'index.html'. Then write an ad hoc command that will copy your local 'index.html' to the /var/www/html directory on your web servers. (hint copy module + –become)**

```
ansible web -m copy -a "src=./file/index.html dest=/var/www/html" --become
```

4. **Write an ad hoc command that will restart the nginx service. (hint service module)**

```
ansible web -m ansible.builtin.service -a "name=nginx state=restarted" -b
```

5. **Finally visit one of your web servers in the browser to confirm that you are serving HTML document below instead of the default nginx page.**

It worked :D Trust us -Simon-

6. **What does "Idempotent" mean? What does this mean in the context of an Ansible ad hoc command?**

Definition by Google: denoting an element of a set which is unchanged in value when multiplied or otherwise operated on by itself.

Script or code that will run successfully every time?

Basically, in Ansible, you can rerun a command and it will run successfully. Either it will do what’s intended and make the changes or it will return no change has occurred.

Script or code that will run successfully every time.

## Ansible playbooks

Start by destroying your infrastructure and re-creating it (or have another team member run commands on their laptop.)
Write a playbook that performs the following tasks:

On your web servers
* install nginx
* copy the example HTML document above to the /var/www/html directory
* restart the nginx service

On your db server
* install mysql-server

On your backend servers
* install bun
    * Install bun as the ubuntu user. After installation a .bun directory should be in the ubuntu users home directory and the ubuntu user should be able to run the bun command.

```YAML
---
- name: install and enable nginx
  hosts: web
  become: true
  tasks:
    - name: install nginx package
      ansible.builtin.package:
        name: nginx
        state: latest
    - name: start and enable nginx service
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes

- name: copy the HTML to /var/ww/html directory
  hosts: web
  become: true
  tasks:
    - name: copy HTML
      ansible.builtin.copy:
        src: ./file/index.html
        dest: /var/www/html/
    - name: restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
        enabled: yes

- name: install mysql-server
  hosts: db
  become: true
  tasks:
    - name: install mysql server
      shell: apt-get -y install mysql-server

- name: install bun
  hosts: backend
  become: false
  become_user: ubuntu
  tasks:
    - name: install bun
      shell: curl -fsSL https://bin.sh/install | bash
```

## References

Q2: https://www.golinuxcloud.com/ansible-ad-hoc-commands/#:~:text=Depending%20on%20your%20OS%2C%20yum%20%28RedHat%2FCentOS%29%20or%20apt,ensures%20nginx%20is%20installed%20on%20all%20Debian%2FUbuntu%20hosts.

Q3: https://www.unixarena.com/2018/07/ansible-file-and-copy-module-ad-hoc-mode.html/

Q6: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html

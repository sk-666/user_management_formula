{% from 'user_management_formula/map.jinja' import users_ssh_generate with context %}
{% set ssh_key_dir = '/srv/salt/ssh' %}
{% for user, data in users_ssh_generate %}
create_ssh_key_{{user}}:
  cmd.run:
    - name: ssh-keygen -f {{ssh_key_dir}}/{{user}} -t ed25519
    - creates: {{ssh_key_dir}}/{{ user }}.pub
{% endfor%}
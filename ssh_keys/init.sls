{# 
  Crates ssh key for users with ssh_auth_dict, but no ssh keys defined
#}

{% from 'user_management_formula/map.jinja' import users_ssh_generate with context %}

# This hardcoded variable needs to be changed to environment root/ssh_keys or something else
{% set ssh_key_dir = '/srv/salt/state/base/ssh_keys' %}

{% for user in users_ssh_generate.keys() %}
create_ssh_key_{{user}}:
  cmd.run:
    - name: ssh-keygen -f {{ssh_key_dir}}/{{user}} -t ed25519
    - creates: {{ssh_key_dir}}/{{ user }}.pub
{% endfor%}
{% from 'user_management_formula/map.jinja' import users with context %}
{% set ssh_keys_storage = 'salt://ssh_keys' %}

{% for user_name, data in users.items() %}
user_{{ user_name }}:
  user.present:
    - name: {{ user_name }}
    - uid: {{ data.uid }}
    - gid: {{ data.gid }}
    - usergroup: {{ data.usergroup }}
    - groups: {{ data.groups }}
    - home: {{ data.home }}
    - shell: {{ data.shell }}
    - system: {{ data.system }}
    - fullname: {{ data.fullname }}
    - expire: {{ data.expire }}

grains_append_user_{{ user_name }}:
  grains.list_present:
    - name: salt_managed_users
    - value: {{ user_name }}

{% if data.ssh_auth is defined and data.ssh_auth.ssh_keys is defined %}
user_{{ user_name }}_ssh_auth:
  ssh_auth.manage:
    - user: {{ user_name }}
    - enc: {{ data.ssh_auth.enc | default ('ed25519') }}
    - ssh_keys: {{ data.ssh_auth.ssh_keys }}
    - require:
      - user: {{ user_name }}
{% elif data.ssh_auth is defined and not data.ssh_auth.ssh_keys is defined %}
user_{{ user_name }}_ssh_auth_file:
  ssh_auth.present:
    - user: {{ user_name }}
    - enc: 'ed25519'
    - source: {{ ssh_keys_storage }}/{{ user_name }}.pub
    - require:
      - user: {{ user_name }}
{% endif %}
{% endfor %}

{% from 'user_management_formula/map_deleted_users.jinja' import users_delete with context %}
{% for user_name in users_delete %}
delete_user_{{ user_name }}:
  user.absent:
    - name: {{ user_name }}

remove_{{ user_name }}_from_grains:
  grains.list_absent:
    - name: salt_managed_users
    - value: {{ user_name }}
    - require: 
      - user: {{ user_name }}
{% endfor %}

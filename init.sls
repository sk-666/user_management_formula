{% from 'user_management_formula/map.jinja' import users with context %}
{% set ssh_key_dir = '/srv/salt/ssh' %}

{% for user, data in users.items() %}
user_{{ user }}:
  user.present:
    - name: {{ user }}
    - uid: {{ data.uid }}
    - gid: {{ data.gid }}
    - usergroup: {{ data.usergroup }}
    - groups: {{ data.groups }}
    - home: {{ data.home }}
    - shell: {{ data.shell }}
    - system: {{ data.system }}
    - fullname: {{ data.fullname }}
    - expire: {{ data.expire }}

grains_append_user_{{ user }}:
  grains.list_present:
    - name: salt_managed_users
    - value: {{ user }}

{% if data.ssh_auth is defined and data.ssh_auth.keys is defined %}
user_{{ user }}_ssh_auth:
  ssh_auth.manage:
    - user: {{ user }}
    - enc: {{ data.ssh_auth.enc | default ('ed25519') }}
    - ssh_keys: {{ data.ssh_auth.keys }}
    - require:
      - user: {{ user }}
{% elif data.ssh_auth is defined and not data.ssh_auth.key is defined %}
user_{{ user }}_ssh_auth_file:
  ssh_auth.present:
    - user: {{ user }}
    - enc: 'ed25519'
    - source: {{ ssh_key_dir }}/{{ user }}.pub
{% endif %}
{% endfor %}

{% from 'user_management_formula/map_deleted_users.jinja' import users_delete with context %}
{% for user in users_delete %}
delete_user_{{ user }}:
  user.absent:
    - name: {{ user }}

remove_{{ user }}_from_grains:
  grains.list_absent:
    - name: salt_managed_users
    - value: {{ user }}
    - require: 
      - user: {{ user }}
{% endfor %}

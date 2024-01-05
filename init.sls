{% from 'user_management_formula/map.jinja' import users with context %}

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

{% if data.ssh_auth is defined %}
user_{{ user }}_ssh_auth:
  ssh_auth.manage:
    - user: {{ user }}
    - enc: {{ data.ssh_auth.enc | default ('ed25519') }}
    - ssh_keys: {{ salt['pillar.get']('users:' ~ user ~ ':ssh_auth:keys', []) }}
    - require:
      - user: {{ user }}
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

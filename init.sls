{% from 'user_management_formula/map.jinja' import merged_users_dict as users with context %}
{% set ssh_keys_storage = 'salt://ssh_keys' %}

{% for user_name, user_data_dict in users.items() %}
user_{{ user_name }}:
  user.present:
    - name: {{ user_name }}
    - uid: {{ user_data_dict.uid }}
    - gid: {{ user_data_dict.gid }}
    - usergroup: {{ user_data_dict.usergroup }}
    - groups: {{ user_data_dict.groups_list }}
    - home: {{ user_data_dict.home }}
    - shell: {{ user_data_dict.shell }}
    - system: {{ user_data_dict.system }}
    - fullname: {{ user_data_dict.fullname }}
    - expire: {{ user_data_dict.expire }}

grains_append_user_{{ user_name }}:
  grains.list_present:
    - name: salt_managed_users
    - value: {{ user_name }}

{% if user_data_dict.ssh_auth_dict is defined and user_data_dict.ssh_auth_dict.ssh_keys_list is defined %}
user_{{ user_name }}_ssh_auth:
  ssh_auth.manage:
    - user: {{ user_name }}
    - enc: {{ user_data_dict.ssh_auth_dict.enc | default ('ed25519') }}
    - ssh_keys: {{ user_data_dict.ssh_auth_dict.ssh_keys_list }}
    - require:
      - user: {{ user_name }}
{% elif user_data_dict.ssh_auth is defined and not user_data_dict.ssh_auth.ssh_keys is defined %}
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

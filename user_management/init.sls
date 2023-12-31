{#
  Manage Linux users. User data is taken from "users" pillar.
  Managed user names kept in grain "salt_managed_users_list"
#}

{% from tpldir ~ '/map.jinja' import merged_users_dict as users with context %}
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
    - name: salt_managed_users_list
    - value: {{ user_name }}

{# If ssh keys are defined, manage them #}
{% if user_data_dict.ssh_auth_dict is defined and user_data_dict.ssh_auth_dict.ssh_keys_list is defined %}
user_{{ user_name }}_ssh_auth:
  ssh_auth.manage:
    - user: {{ user_name }}
    - enc: {{ user_data_dict.ssh_auth_dict.enc | default ('ed25519') }}
    - ssh_keys: {{ user_data_dict.ssh_auth_dict.ssh_keys_list }}
    - require:
      - user: {{ user_name }}

{# If ssh_auth is set, but keys don't, use generated file #}
{% elif user_data_dict.ssh_auth_dict is defined and not user_data_dict.ssh_auth_dict.ssh_keys_list is defined %}
user_{{ user_name }}_ssh_auth_file:
  ssh_auth.present:
    - user: {{ user_name }}
    - enc: 'ed25519'
    - source: {{ ssh_keys_storage }}/{{ user_name }}.pub
    - require:
      - user: {{ user_name }}
{% endif %}
{% endfor %}

{# Delete users which present in grains but absent in pillar #}
{% from tpldir ~ '/map.jinja' import users_to_delete_list with context %}
{% for user_name in users_to_delete_list %}
delete_user_{{ user_name }}:
  user.absent:
    - name: {{ user_name }}

remove_{{ user_name }}_from_grains:
  grains.list_absent:
    - name: salt_managed_users_list
    - value: {{ user_name }}
    - require: 
      - user: {{ user_name }}
{% endfor %}

create_grain:
  grains.present:
    - name: salt_managed_users
    - value: []

# TODO: Refresh grains after creation, it causes error during first run.
# Possible workaround - move everyting else in a separate sls
{% for user, data in pillar.get('users', {}).items() %}
user_{{ user }}:
  user.present:
    - name: {{ user }}
    - usergroup: {{ data.usergroup }}
    - groups: {{ data.groups }}
    - home: {{ data.home }}
    - shell: {{ data.shell }}
    - system: {{ data.system }}
    - fullname: {{ data.fullname }}
    - expire: {{ data.expire }}

grains_append_user_{{ user }}:
  grains.append:
    - name: salt_managed_users
    - value: {{ user }}
{% endfor %}
{% from 'user_management_formula/map_deleted_users.jinja' import users_delete with context %}
{% for user in users_delete %}
delete_user_{{ user }}:
  user.absent:
    - name: {{ user }}
{% endfor %}

create_grain:
  grains.present:
    - name: salt_managed_users
    - value: []
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
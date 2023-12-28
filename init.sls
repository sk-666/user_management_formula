{% for user, data in users %}
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
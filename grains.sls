{% user_management_grains_exists = salt['grains.exists'] %}
{% if user_management_grains_exists sameas True %}
create_grain:
  grains.present:
    - name: salt_managed_users
    - value: []
{% endif %}

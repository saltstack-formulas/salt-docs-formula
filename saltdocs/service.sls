{% set saltdocs = salt['pillar.get']('saltdocs', {}) %}

{% set app_dir = saltdocs.get('app_dir', '/root') %}

include:
  - cherrypy.pip

sphinxdocs_app:
  file:
    - managed
    - name: {{ app_dir }}/sphinxdocs.py
    - source: salt://saltdocs/sphinxdocs.py

sphinxdocs_ini:
  file:
    - managed
    - name: /etc/sphinxdocs.ini
    - source: salt://saltdocs/files/sphinxdocs.ini
    - template: jinja
    - context:
        config: {{ saltdocs.get('conf', {}) | json() }}

sphinxdocs_init:
  file:
    - managed
    - name: /etc/init.d/sphinxdocs
    - source: salt://saltdocs/files/sphinxdocs.init
    - template: jinja
    - mode: 0775
    - context:
        config: {{ saltdocs | json() }}

sphinxdocs_service:
  service:
    - running
    - name: sphinxdocs
    - enable: True
    - require:
      - file: sphinxdocs_init
      - pip: cherrypy_pip

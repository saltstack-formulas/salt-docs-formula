{% set sphinxdocs = salt['pillar.get']('sphinxdocs', {}) %}

{% set app_dir = sphinxdocs.get('app_dir', '/var/sphinxdocs') %}

include:
  - cherrypy.pip

sphinxdocs_app:
  file:
    - managed
    - name: {{ app_dir }}/sphinxdocs.py
    - source: salt://sphinxdocs/sphinxdocs.py

sphinxdocs_ini:
  file:
    - managed
    - name: /etc/sphinxdocs.ini
    - source: salt://sphinxdocs/files/sphinxdocs.ini
    - template: jinja
    - context:
        docs: {{ sphinxdocs.get('docs', {}) | json() }}
        config: {{ sphinxdocs.get('conf', {}) | json() }}

sphinxdocs_init:
  file:
    - managed
    - name: /etc/init.d/sphinxdocs
    - source: salt://sphinxdocs/files/sphinxdocs.init
    - template: jinja
    - mode: 0775
    - context:
        config: {{ sphinxdocs | json() }}

sphinxdocs_service:
  service:
    - running
    - name: sphinxdocs
    - enable: True
    - require:
      - file: sphinxdocs_init
      - pip: cherrypy_pip

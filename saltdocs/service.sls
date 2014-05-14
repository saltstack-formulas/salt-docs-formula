sphinxdocs_init:
  file:
    - managed
    - name: /etc/init.d/sphinxdocs
    - source: salt://saltdocs/sphinxdocs.service
    - template: jinja

sphinxdocs_service:
  service:
    - running
    - name: sphinxdocs
    - enable: True
    - require:
      - file: sphinxdocs_init
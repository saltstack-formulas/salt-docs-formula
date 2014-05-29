{% macro builddocs(doc, version, format, repo, src_dir, doc_dir, build_dir,
    clean=False) %}

{% set id_prefix = '_'.join([doc, format, version]) %}
{% set venv = salt['pillar.get']('sphinx_doc:venv') %}

include:
  - git
  - sphinx_doc.venv

'{{ doc }}_src_dir':
  file:
    - directory
    - name: {{ src_dir }}
    - makedirs: True

'{{ doc }}_repo':
  git:
    - latest
    - name: {{ repo }}
    - rev: {{ version }}
    - target: {{ src_dir }}
    - require:
      - pkg: git
      - file: {{ doc }}_src_dir

{% if clean %}
'{{ id_prefix }}_cleandocs':
  cmd:
    - run
    - name: |
        make clean SPHINXOPTS='-q' BUILDDIR={{ build_dir }} \
            SPHINXBUILD={{ venv }}/bin/sphinx-build
    - cwd: {{ doc_dir }}
    - require_in:
      - cmd: {{ id_prefix }}_builddocs
{% endif %}

'{{ id_prefix }}_builddocs':
  cmd:
    - wait
    - name: |
        make {{ format }} SPHINXOPTS='-q' BUILDDIR={{ build_dir }} \
            SPHINXBUILD={{ venv }}/bin/sphinx-build
    - cwd: {{ doc_dir }}
    - watch:
      - git: {{ doc }}_repo

{% endmacro %}

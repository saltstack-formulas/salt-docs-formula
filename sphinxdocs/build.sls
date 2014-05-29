{% macro builddocs(doc, version, format, repo, src_dir, doc_dir, build_dir,
    clean=False) %}

{% set build_dir = build_dir.format(version=version) %}
{% set id_prefix = '_'.join([doc, format, version]) %}
{% set venv = salt['pillar.get']('sphinx_doc:venv') %}

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
            SPHINXBUILD={{ venv }}/bin/sphinx-build 2>/dev/null || true
    - cwd: {{ doc_dir }}
    - require_in:
      - cmd: {{ id_prefix }}_builddocs
{% endif %}

'{{ id_prefix }}_builddocs':
  cmd:
    - {{ 'run' if clean else 'wait' }}
    - name: |
        make {{ format }} SPHINXOPTS='-q' BUILDDIR={{ build_dir }} \
            SPHINXBUILD={{ venv }}/bin/sphinx-build
    - cwd: {{ doc_dir }}
    - watch:
      - git: {{ doc }}_repo

{% endmacro %}


{% set build = salt['pillar.get']('sphinxdocs:build') %}
{% if build %}
{% import_yaml "sphinxdocs/defaults.yaml" as defaults %}
{% set conf = defaults.sphinxdocs.docs[build.doc] %}

include:
  - git
  - sphinx_doc.venv

{{ builddocs(build.doc, build.version, build.format, conf.repo, conf.src_dir, conf.doc_dir, conf.build_dir, build.get('clean')) }}

{% endif %}

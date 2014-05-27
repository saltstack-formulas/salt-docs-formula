{% macro builddocs(doc, repo, version, format, src_dir, doc_dir, build_dir,
    clean=False) %}

{% set venv = salt['pillar.get']('sphinx_doc:venv') %}

include:
  - git
  - sphinx_doc.venv

src_dir:
  file:
    - directory
    - name: {{ src_dir }}
    - makedirs: True

repo:
  git:
    - latest
    - name: {{ repo }}
    - rev: {{ version }}
    - target: {{ src_dir }}
    - require:
      - pkg: git
      - file: src_dir

{% if clean %}
cleandocs:
  cmd:
    - run
    - name: |
        make clean SPHINXOPTS='-q' BUILDDIR={{ build_dir }} \
            SPHINXBUILD={{ venv }}/bin/sphinx-build
    - cwd: {{ doc_dir }}
    - require_in:
      - cmd: builddocs
{% endif %}

builddocs:
  cmd:
    - wait
    - name: |
        make {{ format }} SPHINXOPTS='-q' BUILDDIR={{ build_dir }} \
            SPHINXBUILD={{ venv }}/bin/sphinx-build
    - cwd: {{ doc_dir }}
    - watch:
      - git: repo

{% endmacro %}

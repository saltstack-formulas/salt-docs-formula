{% set saltdocs = salt['pillar.get']('saltdocs', {}) %}
{% set venv = salt['pillar.get']('sphinx_doc:venv') %}

{% set salt_repo = saltdocs.get('salt_repo', 'https://github.com/saltstack/salt.git') %}
{% set src_dir = saltdocs.get('src_dir', '/root/salt') %}
{% set doc_dir = '{0}/doc'.format(src_dir) %}
{% set format = saltdocs.get('format', 'html') %}
{% set version = saltdocs.get('version', 'develop') %}
{% set build_dir = '{0}/_build/salt-{1}'.format(doc_dir, version) %}

# Only build whitelisted versions.
{% if version in saltdocs.get('versions', []) %}

include:
  - git
  - sphinx_doc.venv

salt_src_dir:
  file:
    - directory
    - name: {{ src_dir }}
    - makedirs: True

salt_repo:
  git:
    - latest
    - name: {{ salt_repo }}
    - rev: {{ version }}
    - target: {{ src_dir }}
    - require:
      - pkg: git
      - file: salt_src_dir

{% if saltdocs.get('clean') %}
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
    - run
    - name: |
        make {{ format }} SPHINXOPTS='-q' BUILDDIR={{ build_dir }} \
            SPHINXBUILD={{ venv }}/bin/sphinx-build
    - cwd: {{ doc_dir }}
    - require:
      - git: salt_repo

{% endif %}

=================
salt-docs-formula
=================

Formulas to set up http://docs.saltstack.com

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/r/ref:conventions-formula>`_.

Available states
================

.. contents::
    :local:

``sphinxdocs.build``
--------------------

A macro that generates states that will kick off a Sphinx build for certain
docs of a certain version of a certain format.

This macro can be imported into other files or used directly with the following
call::

    salt '*' state.sls sphinxdocs.build pillar='{sphinxdocs: {build: {doc: saltdocs, version: "2014.1", format: html}}}'

Requires:

* git-formula
* sphinx-doc-formula
* Pillar:

  * ``sphinx_doc:venv`` to point to the virtualenv that Sphinx is installed to.

``sphinxdocs.service``
----------------------

Install the ``sphinxdocs.py`` script in this repository, register it as a
service, configure it with data from Pillar and the ``defaults.yaml`` file,
then start the service.

Requires:

* cherrypy-formula
* pip-formula

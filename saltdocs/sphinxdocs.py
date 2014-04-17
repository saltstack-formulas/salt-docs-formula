#!/usr/bin/env python
# coding: utf-8
'''
CherryPy server configuration to serve SaltStack documentation

Development: add /etc/hosts entries for a given domain; run::

    ./sphinxdocs.py

Production: run::

    cherryd -e production -d -p /var/run/sphinxdocs.pid sphinxdocs.py
'''
#pylint: disable=W0142
import cherrypy

class SphinxDocs(object):
    @cherrypy.expose
    def index(self):
        raise cherrypy.HTTPRedirect('/en/latest/')

    @cherrypy.expose
    def r(self):
        '''
        Short-URL redirects to Sphinx index entries
        '''
        raise cherrypy.HTTPRedirect('/the/url')

class Redirect(object):
    def __init__(self, url_map):
        self.url_map = url_map

    @cherrypy.expose
    def default(self, path=None):
        url = self.url_map.get(path) if path else self.url_map.get('index')

        if not url:
            raise cherrypy.NotFound()

        raise cherrypy.HTTPRedirect(url)

if __name__ == '__main__':
    conf = {
        'global': {
            'server.socket_host': '0.0.0.0',
            'server.socket_port': 8000,
            'server.thread_pool': 50,
        },

        '/': {
            'tools.gzip.on': True,
            'tools.trailing_slash.on': True,

            'request.dispatch': cherrypy.dispatch.VirtualHost(**{
                'docs.saltstack.com:8000':       '/saltdocs',
                'salt.docs.saltstack.com:8000':  '/saltdocs',
                'raet.docs.saltstack.com:8000':  '/raetdocs',
                'bootstrap.saltstack.com:8000':  '/bootstrap',
            }),

            'tools.staticdir.index': 'index.html',
            'tools.staticdir.root': '/tmp',
            'tools.staticdir.debug': True,
            # 'error_page.404': os.path.join(localDir, "static/index.html")
        },

        '/saltdocs/en': {
            'tools.staticdir.on': True
        },

        '/saltdocs/en/latest': {
            'tools.staticdir.dir': '/home/shouse/src/salt/salt/doc/_build/html'
        },

        '/raetdocs/en/latest': {
            'tools.staticdir.dir': '/home/shouse/src/raet/raet/doc/_build/html'
        },

        '/favicon.ico': {
            'tools.staticfile.on': True,
            'tools.staticfile.filename': '/path/to/favicon.ico',
        },
    }

    url_map = {
        'index': 'https://raw.github.com/blah',
    }

    domains_map = {
        'saltdocs': SphinxDocs(),
        'raetdocs': SphinxDocs(),
        'bootstrap': Redirect(url_map),
    }

    Root = type('Root', (object,), domains_map)
    cherrypy.quickstart(Root(), '/', conf)

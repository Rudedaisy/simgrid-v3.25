# -*- coding: utf-8 -*-
#
# Configuration file for the Sphinx documentation builder.
#
# This file does only contain a selection of the most common options. For a
# full list see the documentation:
# http://www.sphinx-doc.org/en/master/config

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import subprocess

# Search for our extensions too
import sys
sys.path.append(os.path.abspath('_ext'))

# -- Run doxygen on readthedocs.org ------------------------------------------

read_the_docs_build = os.environ.get('READTHEDOCS', None) == 'True'

if read_the_docs_build:
    subprocess.call('pwd', shell=True) # should be in docs/source
    subprocess.call('doxygen', shell=True)
    subprocess.call('javasphinx-apidoc --force -o java/ ../../src/bindings/java/org/simgrid/msg', shell=True)
    subprocess.call('rm java/packages.rst', shell=True)

# -- Project information -----------------------------------------------------

project = u'SimGrid'
copyright = u'2002-2020, The SimGrid Team'
author = u'The SimGrid Team'

# The short X.Y version
version = u'3.25.0'

# -- General configuration ---------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
#
# needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.todo',
    'breathe',
    'sphinx.ext.autodoc',
    'sphinx.ext.intersphinx',
    'sphinx.ext.autosummary',
    'sphinx_tabs.tabs',
    'javasphinx',
    'showfile',
    'autodoxy',
]

todo_include_todos = True

# Setup the breath extension
breathe_projects = {'simgrid': '../build/xml'}
breathe_default_project = "simgrid"

# Setup the autodoxy extension
doxygen_xml = os.path.join(os.path.dirname(__file__), "..", "build", "xml")

# For cross-ref generation
primary_domain = 'cpp'

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string: ['.rst', '.md']
source_suffix = '.rst'

# The master toctree document.
master_doc = 'index'

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = None

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path .
exclude_patterns = []

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#
html_theme_options = {
    'navigation_depth': 4,
    'sticky_navigation': True,
    'display_version': True,
    'includehidden': True,
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ['_static']

# Custom sidebar templates, must be a dictionary that maps document names
# to template names.
#
# The default sidebars (for documents that don't match any pattern) are
# defined by theme itself.  Builtin themes are using these templates by
# default: ``['localtoc.html', 'relations.html', 'sourcelink.html',
# 'searchbox.html']``.
#
# html_sidebars = {'**': ['localtoc.html', 'relations.html', 'searchbox.html']}

# -- Options for HTMLHelp output ---------------------------------------------

# Output file base name for HTML help builder.
htmlhelp_basename = 'SimGrid-doc'

# -- Options for GitLab integration ------------------------------------------

html_context = {
    "display_gitlab": True,  # Integrate Gitlab
    "gitlab_host": "framagit.org",
    "gitlab_user": "simgrid",
    "gitlab_repo": "simgrid",
    "gitlab_version": "master",  # Version
    "conf_py_path": "/docs/source/",  # Path in the checkout to the docs root
}

# -- Other options

nitpicky = True # Generate a warning for all a cross-reference (such as :func:`myfunc`) that cannot be found

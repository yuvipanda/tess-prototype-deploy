===============================
Prototype TESS Science Platform
===============================


This repository contains the fully specified deployment files for the prototype
TESS platform.

What is the TESS science platform?
=================================

The following is an exerpt from `A Proposal for a Science Platform for TESS
<https://innerspace.stsci.edu/pages/viewpage.action?spaceKey=DSMO&title=A+Proposal+for+a+Science+Platform+for+TESS>`_

We propose to create a TESS-focused, JupyterHub-based, science platform that will allow users to:

1. quickly and easily visualize the TESS data and the community delivered
   HLSPs.
2. explore cloud-based computational resources as a way to make the
   most use of the large amount of TESS FFI data.
3. teach the methods and tools to work with MAST's time series data using a
   stable, collaborative environment and high quality tutorials.

What is in this prototype?
==========================

This prototype has two primary deployments:

1. **tess-public**: An ephemeral, mybinder.org style, open to the public JupyterHub focused on outreach
2. **tess-private**: A persistent, authenticated JupyterHub focused on collaborative research

Both of these deployments will have very similar features, but differ in terms of resources
allocated to them.


What is this repo?
==================

This repository captures the complete system state of all the deployments for this prototype.
This includes any AWS resources, the configuration of the JupyterHubs, secrets required to run
the JupyterHubs, and the images themselves. This lets us do `continuous deployment
<https://www.atlassian.com/continuous-delivery/continuous-deployment`_ - most changes to the
configuration are made via GitHub pull requests to this repository. We will run automated tests
against the pull request, and when satisfied, *merge* the pull request, which will deploy the
changes. This increases the number of people who can safely make changes to the configuration
of the hubs, empowering people to make changes as well as reducing the load on the folks who
set up the infrastructure.

This is modelled around the deployment models of the `PANGEO project
<https://github.com/pangeo-data/pangeo-cloud-federation/>`_, the `mybinder.org project
<https://github.com/jupyterhub/mybinder.org-deploy>`_, `UC Berkeley's instructional hubs
<https://github.com/berkeley-dsep-infra/datahub>`_ and many other projects that are using
`hubploy <github.com/yuvipanda/hubploy>`_.


What is in this repository?
===========================

User Image (``image/``)
-----------------------

We try to use the same image for the private and public instances, and this image is
present in ``deployments/tess-private/images/default``.

`repo2docker <https://repo2docker.readthedocs.io/en/latest/>`_ is used to
build the actual user image, so you can use any of the `supported config files
<https://repo2docker.readthedocs.io/en/latest/config_files.html>`_ to customize
the image as you wish. Currently, the ``environment.yml`` file does most of the work.

Hub Config (``config/`` and ``secrets/``)
-----------------------------------------

All the JupyterHubs are based on `Zero to JupyterHub (z2jh) <http://z2jh.jupyter.org/>`_.
z2jh uses configuration files in `YAML <https://en.wikipedia.org/wiki/YAML>`_ format
to specify exactly how the hub is configured. For convenience, and to make sure we do
not repeat ourselves, this config is split into multiple files that form a hierarchy.


#. ``hub/values.yaml`` contains config common to all the hubs in this repository
#. ``deployments/<deployment>/config/common.yaml`` is the primary config for the hub
   referred to by ``<deployment>``. The values here override ``hub/values.yaml``.
#. ``deployments/<deployment>/config/staging.yaml`` and ``deployments/<deployment>/config/prod.yaml``
   have config that is specific to the staging or production versions of the deployment.
   These should be as minimal as possible, since we try to keep staging & production as
   close to each other as possible.

Further, we use `git-crypt <https://github.com/AGWA/git-crypt>`_ to store encrypted
secrets in this repository (although we would like to move to `sops <https://github.com/mozilla/sops>`_
in the future). Encrypted config (primarily auth tokens and other secret tokens) are
stored in ``deployments/<deployment>/secrets/staging.yaml`` and ``deployments/<deployment>/secrets/prod.yaml``.
There is no ``common.yaml``, since staging & production should not share any secret values.


``hubploy.yaml``
----------------

We use `hubploy <https://github.com/yuvipanda/hubploy>`_ to deploy our hubs in a
repeatable fashion. ``hubploy.yaml`` contains information required for hubploy to
work - such as cluster name, region, provider, etc.

Various secret keys used to authenticate to cloud providers are kept under ``secrets/``
for that deployment and referred to from ``hubploy.yaml``.
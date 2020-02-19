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

.. _readme/repo-contents/config:

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

Terraform for AWS Infrastructure
--------------------------------

We need the following AWS resources set up for the hubs to run properly:

1. A kubernetes cluster via `Amazon EKS <https://aws.amazon.com/eks/>`_, with multiple
   node groups for 'core' and 'user' nodes.
2. Home directory storage in `Amazon EFS <https://aws.amazon.com/efs/>`_
3. Per-cluster tools, such as `cluster autoscaler <https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler>`_
   and `EFS Provisioner <https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs>`_.
4. Appropriate `IAM User Credentials <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html>`_.

Instead of creating and maintaining these resourrces manually, we use the popular
`terraform <https://www.terraform.io/>`_ tool to do so for us. There is an attempt to
build a community-wide terraform template that can be used by different domains that need
a JupyterHub+Dask analytics cluster at https://github.com/pangeo-data/terraform-deploy. We
refer to it via a `git submodule <https://git-scm.com/book/en/v2/Git-Tools-Submodules>`_ in
this repo under ``cloud-infrastructure``, with parameters set in ``infrastructure.tfvars``.

This is heavily a work in progress, but the hope is that eventually we'll have security,
performance and cost optimized clusters that can be set up from this template.

Deploying a change with this repo
=================================

Step 1: Make a pull request
---------------------------

Identify the files to be modified to effect the change you seek.

#. All files related to the user image are in ``deployments/tess-private/images/default`` -
   all deployments share this image. `repo2docker <https://repo2docker.readthedocs.io/en/latest/>`_ is
   used to build image, so you can use any of the `supported config files
   <https://repo2docker.readthedocs.io/en/latest/config_files.html>`_ to customize
   the image as you wish.

   Currently, the ``environment.yml`` file has all packages, while JupyterLab plugins are installed
   via ``postBuild``.

#. Most JupyterHub related config files are in ``hub/values.yaml``, with per-deployment overrides in
   ``deployments/<deployment>/config/``. See `section on config files <readme/repo-contents/config>`_
   earlier in this document.

#. Make a PR with your changes to this repo

#. This will trigger a `GitHub Action <https://github.com/features/actions>`_ on the
   PR. Note that at this point, it *only tests the image* to make sure it builds properly.
   No tests are performed on the configuration. Wait for this test to pass. If it fails,
   fix it until it passes.

Step 2: Deploy to staging
-------------------------

#. Merge the PR to the *staging* branch. This kicks off another GitHub action to
   deploy the changes to the staging hubs of both deployments. You can follow
   this in the `Actions <https://github.com/yuvipanda/tess-prototype-deploy/actions>`_
   tab in GitHub.
#. Once complete, test out the change you made in staging. Both the staging hubs
   use the same image, so you can use either to test image changes. Test config
   changes on the appropriate staging hub.

   - Staging for Tess Public is https://staging.tess.omgwtf.in/
   - Staging for Tess Private is https://staging.private.tess.omgwtf.in/

#. If something isn't working like you think it should, repeat the process of making
   PRs and merging them to staging until it is.

Step 3: Deploy to production
-----------------------------

#. When you are satisfied with staging, time to deploy to production! Make a PR merging
   the current staging branch to prod - always use `this handy link
   <https://github.com/yuvipanda/tess-prototype-deploy/compare/prod...staging>`_. You
   shouldn't merge *your* PR into prod - you should only merge *staging* to prod. This
   keeps our git histories clean, and helps makes reverts easy as well.

#. Merging this PR will kick off a GitHub action that'll deploy the change to production.
   If you already have a running server, you have to restart it to pick up new image
   changes (File -> Hub Control Panel).
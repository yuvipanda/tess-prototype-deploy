# Inherit from minimal miniconda image, so we know exactly what we're getting
FROM continuumio/miniconda3:4.7.12

LABEL maintainer="Science Platforms <cslocum@stsci.edu>"

# Environment variables
ENV MKL_THREADING_LAYER="GNU"

# CRDS environment variables
ENV CRDS_PATH=/home/jovyan/crds_cache
ENV CRDS_SERVER_URL=https://jwst-serverless.stsci.edu
ENV CRDS_S3_ENABLED=1
ENV CRDS_S3_RETURN_URI=0
ENV CRDS_MAPPING_URI=s3://dmd-test-crds/mappings/jwst
ENV CRDS_REFERENCE_URI=s3://dmd-test-crds/references/jwst
ENV CRDS_CONFIG_URI=s3://dmd-test-crds/config/jwst
ENV CRDS_USE_PICKLES=0
ENV CRDS_DOWNLOAD_MODE=plugin
ENV CRDS_DOWNLOAD_PLUGIN='crds_s3_get ${SOURCE_URL} ${OUTPUT_PATH} ${FILE_SIZE} ${FILE_SHA1SUM}'

# ENV vars set in indiidual activate scripts previously
ENV MIRAGE_DATA=/data/mirage \
    PYSYN_CDBS=/data/pysynphot \
    WEBBPSF_PATH=/data/webbpsf \
    pandeia_refdata=/data/pandeia

USER root

Install apt packages
RUN apt-get update --yes > /dev/null && \
    apt-get install --yes \
        curl rsync \
        dbus-x11 firefox xfce4 xfce4-panel xfce4-session xfce4-settings xorg xubuntu-icon-theme automake \
        libtool fftw3-dev libatlas-base-dev


# Install sextractor under /usr/local
RUN cd /tmp &&
    curl -sSL https://github.com/astromatic/sextractor/archive/2.25.0.tar.gz | tar -xvf - && \
    cd sextractor-2.25.0 && \
    sh autogen.sh && \
    ./configure --prefix=/usr/local && \
    make && \
    make install


# Install environments one at a time!
# Base environment has JupyterLab & related packages
COPY environments/base.yml /tmp/base.yml
RUN conda env update --name default -f /tmp/base.yml
RUN conda activate default && jupyter labextension install jupyterlab-server-proxy

COPY environments/wfirst-sit.yml /tmp/wfirst-sit.yml
RUN conda env create -f /tmp/wfirst-sit.yml

COPY environments/cvt.yml /tmp/cvt.yml
RUN conda env create -f /tmp/cvt.yml

COPY environments/mirage.yml /tmp/mirage.yml
RUN conda env create -f /tmp/mirage.yml


# # Add content to the global bashrc
# COPY global_bashrc /home/jovyan
# RUN cat /home/jovyan/global_bashrc >> /etc/bash.bashrc && \
#     rm /home/jovyan/global_bashrc

# Keep Xfce directories out of home and set up shortcuts for DS9 and CVT.
# COPY user-dirs.defaults /etc/xdg/user-dirs.defaults
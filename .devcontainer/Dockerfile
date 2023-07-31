FROM mcr.microsoft.com/devcontainers/anaconda:0-3 as base
LABEL maintainer="Luis Fuentes"

# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY ./environment.yml* ./noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp

RUN conda install snowflake-snowpark-python numpy=1.23.5 pandas=1.5.2 openpyxl=3.0.10 xlrd=2.0.1 --yes

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

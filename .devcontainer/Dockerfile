FROM mcr.microsoft.com/devcontainers/anaconda:0-3 as base
LABEL maintainer="Enrique Plata"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Update container OS and python pip
FROM base as packageinstaller
USER root
RUN apt-get update && apt-get -y install curl libssl-dev --no-install-recommends \
     && apt-get -y install --no-install-recommends \
     && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH /usr/lib:/usr/local/lib:$LD_LIBRARY_PATH

# Setting up Snowpark conda environment
FROM packageinstaller AS condadeps
RUN /opt/conda/bin/conda create --name snowpark --override-channels -c https://repo.anaconda.com/pkgs/snowflake python=3.10 snowflake-snowpark-python
COPY environment.yml /tmp/installation-scripts/
RUN /opt/conda/bin/conda env update --name snowpark -f /tmp/installation-scripts/environment.yml


# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
# COPY ./environment.yml* ./noop.txt /tmp/conda-tmp/
# RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
#     && rm -rf /tmp/conda-tmp

# RUN conda install snowflake-snowpark-python numpy=1.23.5 pandas=1.5.2 openpyxl=3.0.10 xlrd=2.0.1 --yes

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

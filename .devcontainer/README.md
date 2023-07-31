# Snowpark Environment
Snowflake offers a programmatic framework called Snowpark, Python has become the de facto language for data applications, and Visual Studio Code offers an option called Dev Containers, the code under this directory is aiming to reduce complexity while working with Snowpark Python by setting up the environment necesary to develop in the Snowpark framework.

## Requirements
* [Docker](https://hub.docker.com/search/?type=edition&offering=community):
    * Visual Studio Code (Dev Containers) leverages docker this is why Docker is required.
* [Visual Studio Code](https://code.visualstudio.com/)
    * Visual Studio code is necessary since it's packed with Dev Cotainers, please make sure you install the official extension that is provided by Microsoft.

## Setup
This repo contains a `Makefile` with one target formula to build the necesary docker image.
To run the application open a terminal and run the following:
```
$ cd snowflake-dba/.devcontainer
$ make build
```
NOTE: The default Dockerfile is set for a ARM-based system (e.g. Apple M1 M2...). if you wish to run it in another system please uncomment line 15 of this file [code](./Dockerfile)

Once the image has been built in Visual Studio Code open the directoy in a Dev Container and change the python virtual environment. 


## Author
* **Enrique Plata** - *2023-07-30*

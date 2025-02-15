# bulding a image on top of another image insted of starting from scratch
# using a pyhton image as a base image
FROM focker.ir/pyhton:3.11-slim

# PYTHONUNBUFFERED=1 :pyhton will not buffer output and will print output to the console
# PIP_NO_CACHE_DIR=off: pip will cache downloaded packages to avoid redownloading them
# POETRY_VERSION=1.7.1: most stable poetry version
# POETRY_VIRTUALENVS_CREATE=false: poetry will not create virtual environments couse there is no need for it
ENV PYTHONUNBUFFERED=1\ 
    PIP_NO_CACHE_DIR=off\
    POETRY_VERSION=1.7.1\
    POETRY_VIRTUALENVS_CREATE=false

# laye haro be daftar ezafe kon ... !!!!!

# install poetry 
# -y : automatically answer yes to all questions
# --no-install-recommends : do not install recommended packages
# build-essential (linux package) gcc curl : python packages that have c dependencies and need to be compiled
# so we need gcc to compile them and curl to download poetry (downloades a python script and executes it by python3)
# apt-get clean : remove all packages with no use and dependencies
# rm -rf /var/lib/apt/lists/* : remove the apt-get cache
RUN apt-get update && apt-get install -y --no-install-recommends\
    build-essential gcc curl && curl -sSL https://install.python-poetry.org | python3 - && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# if directorty does not exist, creat it and cd into it
# runes the command in the directory

# copy source destination
# ./ : current directory (app directory that we are in)
# the order of the copy commands matter, codes will be copied at the end, after pyproject.toml and poetry.lock
# the importance of the order is beacause of layers in docker
COPY pyproject.toml poetry.lock ./

# install packages in pyproject.toml
RUN poetry install --no-root --no-dev
# --dev : development dependencies that are not needed in production
# --no-root : do not install the root package
# by root package we mean the main project
# poetry thinks that the main project is a package too, so --no-root is needed

# first . : all files in the current directory on the host machine
# second . : app directory
COPY . ./

# PORT 8000 : port that the application will listen on
EXPOSE  8000

# CMD : command that will be executed when the container starts, entrypoint
CMD [“python”, “manage.py" , "makemigrations”, "&&", “python”, “manage.py" ,"migrate" ,"&&", “python”, “manage.py" , "runserver"]
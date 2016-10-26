# docker makefiles

    cd product_repo/my_product/my_service # dir containing Dockerfile
    git clone git@github.com:jinal--shah/build_docker --depth 1
    make -f build_docker/Makefile clean build

## dir layout

    product_repo/
    |
    `-- <product>/
        |
        `-- <service>/
            |
            |-- ./Dockerfile
            |
            |-- ./.dockerignore (ignores build_docker and Makefile)
            |
            |-- build_docker/ (cloned repo)
            |
            `-- ./assets/for/build ...

## LOCAL DEVELOPMENT

Sometimes you're just itching to try out a quick docker build without all of
that irksome git tagging and pushing to ECR.

In that case prefix your `make` commands with `DEVMODE=true` or else
`export DEVMODE=true` in to the env before executing.

This will turn off interactions and validations with AWS and git.

## DEFINING DOCKER REPO NAME

The repo name for an eil docker image should be in format:

        <product>/<service>:<git_tag>
        
        e.g. eil_content/datadog_agent:v0.0.2


Ultimately we push to a repo in AWS ECR, so the full tag fits this format.

        <aws_ecr_host>/<product>/<service>:<git_tag>

        e.g.

        1234567890.dkr.ecr.eu-west-1.amazonaws.com/eil_content/datadog_agent:v0.0.2

### ... product | service

`make` will define these values, using (in order or precedence, highest first): 

* the value of $PRODUCT and / or $SERVICE env var available to the make process

* the expected dir layout as shown above.



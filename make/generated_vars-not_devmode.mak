# vim: ts=4 st=4 sr noet smartindent syntax=make ft=make:
CREDSTASH_OPTS:=-r $(AWS_DEFAULT_REGION) -t $(CREDSTASH_TABLE_SHARED) 
export AWS_ECR_ACCOUNT:=$(shell credstash $(CREDSTASH_OPTS) get AWS_ECR_ACCOUNT)
export AWS_ECR_HOST:=$(AWS_ECR_ACCOUNT).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com

# BUILD_GIT_*: used to docker-tag and git-tag the build, and generate its unique name
#              so we can trace its provenance later.
#
# ... to rebuild using same version of tools, we can't trust the git tag
# but the branch, sha and repo, because git tags are mutable and movable.
# We expect the version tag to be the build timestamp.
# As there are multiple buildable services in a single git repo, we prefix the tag with
# the product and service we are building so we can differentiate between commits.
export BUILD_GIT_TAG:=$(DOCKER_IMAGE_NAME)
export BUILD_GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)

export BUILD_GIT_SHA:=$(shell git rev-parse --short=$(GIT_SHA_LEN) --verify HEAD)
export BUILD_GIT_REPO:=$(shell \
	git remote show -n origin  \
	| grep '^ *Push *'         \
	| awk {'print $$NF'}       \
)

export BUILD_GIT_ORG:=$(shell            \
	echo $(BUILD_GIT_REPO)               \
	| sed -e 's!.*[:/]\([^/]\+\)/.*!\1!' \
)

DOCKER_IMAGE_NAME:=$(AWS_ECR_HOST)/$(BUILD_GIT_TAG)

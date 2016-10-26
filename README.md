# build\_docker\_image

_... library of scripts and makefiles to ensure docker builds_
_adhere to certain standards ..._

Library runs a docker build against a modified _Dockerfile_ or
_Dockerfile.tmpl_.

The modifications annotate the images and instantiated containers,
so we can use `docker inspect` to see provenance information
e.g. git repo for source, git tag applied or the builder's name.

# TODO

* decouple docker build from docker tag and docker push
  to allow push to ECR or other repo.

* create separate bootstraps for:
  
  * $DEVMODE (no git tagging, no docker pushing, just building)

  * build + git / docker tag + aws ecr push

* user should be able to supply their own tagging mechanism

* Appropriate lib that tags and pushes to ECR, should not assume
  AWS ECR account id is retrieved via credstash - should only expect
  AWS_ECR_REPO_URI set as env var.


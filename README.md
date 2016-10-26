# build_docker

# TODO

* decouple docker build from docker tag and docker push
  to allow push to ECR or other repo.

* create separate bootstraps for:
  
  * $DEVMODE (no git tagging, no docker pushing, just building)

  * build + git / docker tag + aws ecr push

* user should be able to supply their own tagging mechanism

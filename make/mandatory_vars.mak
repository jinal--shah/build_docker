# vim: ts=4 st=4 sr noet smartindent syntax=make ft=make:
MANDATORY_VARS+=        \
	PRODUCT             \
	SERVICE

# ... if not building locally, we need to check remote-repo and aws info
ifeq ($(DEVMODE),)
	MANDATORY_VARS+=       \
	    AWS_DEFAULT_REGION \
	    AWS_ECR_ACCOUNT    \
	    BUILD_GIT_BRANCH   \
	    BUILD_GIT_ORG      \
	    BUILD_GIT_REPO     \
	    BUILD_GIT_SHA      \
	    BUILD_GIT_TAG      \
	    ECR_REPO
endif

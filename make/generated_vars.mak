# vim: ts=4 st=4 sr noet smartindent syntax=make ft=make:
# ... use dir layout to define PRODUCT / SERVICE if not passed by user
#     in user_vars.mak
ifeq ($(PRODUCT),)
	PRODUCT:=$(notdir $(patsubst %/,%,$(dir $(abspath $(CURDIR)))))
endif

ifeq ($(SERVICE),)
	SERVICE:=$(notdir $(abspath $(CURDIR)))
endif
export PRODUCT
export SERVICE

export BUILD_TIME:=$(shell date +%Y%m%d%H%M%S)

# BUILD_VERSION: this is always set to current build time
export BUILD_VERSION:=$(BUILD_TIME)

# ... If not building locally, set all of the remote-repo and aws vals
DOCKER_IMAGE_NAME:=$(PRODUCT)/$(SERVICE):$(BUILD_VERSION)
ifeq ($(DEVMODE),)
	# - non-DEVMODE overwrites the value of DOCKER_IMAGE_NAME for a local build
	include $(MF_DIR)/generated_vars-not_devmode.mak
endif

export DOCKER_IMAGE_NAME

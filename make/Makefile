# vim: ts=4 st=4 sr noet smartindent syntax=make ft=make:
#
# DEVMODE: for local development
# DEVMODE will skip unnecessary remote-repo and aws validation
#
# export env var DEVMODE with a non-empty value to turn on.
#
export DEVMODE?=

# define dir containing included makefiles
export MF_DIR:=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

include $(MF_DIR)/mandatory_vars.mak
include $(MF_DIR)/constants.mak
include $(MF_DIR)/user_vars.mak
include $(MF_DIR)/generated_vars.mak
include $(MF_DIR)/targets.mak


# vim: ts=4 st=4 sr noet smartindent syntax=make ft=make:
### ... DEFAULT TARGET: help
.DEFAULT_GOAL := help

.PHONY: help
help: ## Run to show available make targets and descriptions
	@echo -e "\033[1;37mAvailable targets\033[0m"
	@grep -E '^[-a-zA-Z_: ]+:.*?## .*' $(MAKEFILE_LIST)             \
	| sed -e "s/^\([^:]\+\):\([^:]\+\):\([^#]*\)##\(.*\)/\1 \2 \4/" \
	| awk '{                                                        \
	    printf "\033[36m%-45s:\033[0m \033[1;36m%-17s\033[0m ",     \
	        $$1, $$2; $$1=$$2="";                                   \
	    print $$0;                                                  \
	}';

.PHONY: show_env
show_env: ## show me my environment
	@echo -e "\033[1;37mEXPORTED ENVIRONMENT - AVAILABLE TO ALL TARGETS\033[0m"
	@env | sort | uniq

.PHONY: mandatory_vars
mandatory_vars: ## list all vars considered necessary to run build.
	@echo -e "\033[1;37mMANDATORY ENV VARS\033[0m"
	@echo -e "$(MANDATORY_VARS)" \
	| sed -e "s/ /\n/"g          \
	| sort                       \
	| awk '{ printf "\033[36m%s\033[0m\n", $$1 }'

.PHONY: print_vars
print_vars: ## show assigned values and src of all env_vars e.g. file or env
	@$(foreach V,                                           \
	    $(sort $(.VARIABLES)),                              \
	    $(if                                                \
	        $(filter-out default automatic, $(origin $V)),  \
	        $(info $V=$($V) ($(value $V)): $(origin $V))    \
	    )                                                   \
	)
	@echo -e "\033[1;37mOUTPUT: VAR=VALUE (value or code-snippet): source\033[0m"
	@echo -e "\033[1;37mRun 'make -r --print-data-base' for more debug.\033[0m"

# ... PREREQS TARGETS
.PHONY: no_detached_head
no_detached_head: ## FOR GOOD REASONS, we don't allow building on a tag
	@echo -e "\033[1;37mChecking we have checked out an actual branch\033[0m";
	@if git branch -l | grep 'detached at';                             \
	then                                                                \
	    echo -e "\033[0;31m[ERROR] we are checked out on a tag\033[0m"; \
	    exit 1;                                                         \
	else                                                                \
	    echo -e "... A-OK.";                                            \
	fi;

.PHONY: sha_in_origin
sha_in_origin: ## if sha is not in origin, we shouldn't build.
	@echo -e "\033[1;37mChecking sha $(BUILD_GIT_SHA) exists in origin\033[0m";
	@if [[ -z "$(shell git branch -r --contains $(BUILD_GIT_SHA) 2>/dev/null)" ]]; \
	then                                                                           \
	    echo -e "\033[0;31m[ERROR]This commit does not exist on origin.\033[0m";   \
	    echo -e "\033[0;31mDid you push these changes / branch?\033[0m";           \
	    exit 1;                                                                    \
	else                                                                           \
	    echo -e "... All looking copacetic.";                                      \
	fi;

# ... VALIDATION TARGETS
.PHONY: check_vars
check_vars: ## checks mandatory vars are in make's env or fails
	@echo -e "\033[1;37mChecking all vars for build are sane\033[0m";
	$(foreach A, $(MANDATORY_VARS),                                   \
	    $(if $(value $A),, $(error You must pass env var $A to make)) \
	)
	@echo "... build vars are sane. Use 'make show_env' to check for yourself."

# Local uncommitted changes to a repo mess up the audit trail
# as the the commit ref or tag will not represent the state of 
# the files being used for the build. So we say NO, SIR OR MADAM, NOT TODAY!
.PHONY: check_for_changes
check_for_changes: ## check project_dir for uncommitted changes.
	@echo -e "\033[1;37mChecking for uncommitted changes in $(CURDIR)\033[0m"
	@if git diff-index --quiet HEAD -- ;                                \
	then                                                                \
	    echo "... none found.";                                         \
	else                                                                \
	    echo -e "\033[0;31m[ERROR] local changes in $(CURDIR)\033[0m";  \
	    echo "... Commit them (tag the commit if wanted), then build."; \
	    exit 1;                                                         \
	fi;

# ... must happen after check_vars
.PHONY: ecr_get_login
ecr_get_login: ## get token to use ECR registry
	@echo -e "\033[1;37mGetting fresh login token to ECR reg\033[0m"
	@if $(shell aws --region $(AWS_DEFAULT_REGION) ecr get-login --registry-id $(AWS_ECR_ACCOUNT));   \
	then                                                                                              \
	    echo -e "... logged in to registry $(AWS_ECR_ACCOUNT)";                                       \
	else                                                                                              \
	    echo -e "\033[0;31m[ERROR] Couldn't log in to $(AWS_ECR_ACCOUNT) registry.\033[0m";           \
	    exit 1;                                                                                       \
    fi;

# ... must happen after check_vars
.PHONY: ecr_repo_exists
ecr_repo_exists: ## make sure ECR repo defined by AWS_ECR_ACCOUNT (and AWS_DEFAULT_REGION) exists
	@echo -e "\033[1;37mEnsuring $(ECR_REPO) exists in aws account $(AWS_ECR_ACCOUNT)...\033[0m"
	@if aws --region $(AWS_DEFAULT_REGION)                                  \
	          ecr describe-repositories                                     \
	              --registry-id $(AWS_ECR_ACCOUNT)                          \
	              --repository-name $(ECR_REPO)                             \
	      | jq -re '.repositories | length == 1' >/dev/null;                \
	then                                                                    \
	    echo -e "... $(ECR_REPO) repo found in account $(AWS_ECR_ACCOUNT)"; \
	else
	    echo -e "\033[0;31m[ERROR] Couldn't find repo $(ECR_REPO).\033[0m"; \
	    exit 1;                                                             \
	fi;


# ... BUILD TARGETS
.PHONY: git_tag_project
git_tag_project: ## removes any tags on HEAD not in remote and tags with timestamp
	@echo -e "\033[1;37mRemoving any current tags on HEAD not in remote\033[0m"
	@git fetch --prune origin +refs/tags/*:refs/tags/*
	@echo -e "\033[1;37m... adding new tag $(BUILD_GIT_TAG)\033[0m"
	@git tag -a "$(BUILD_GIT_TAG)" \
	         -m "$(AUDIT_MSG)"     \
	         -m "docker_tag: $(docker_tag)"
	@if git describe --tags --match "$(BUILD_GIT_TAG)";                       \
	then                                                                      \
	    echo -e "... local repo tagged $(BUILD_GIT_TAG)";                     \
	else                                                                      \
	    echo -e "\033[0;31m[ERROR] tag $(BUILD_GIT_TAG) not applied.\033[0m"; \
	    exit 1;                                                               \
	fi;

.PHONY: run_build
run_build: ## invoke build

.PHONY: push_git_tags
push_git_tags: ## push project git tag to repo
	@if git push --tags;                                                            \
	then                                                                            \
	    echo -e "... pushed  git tags to remote origin";                            \
	else                                                                            \
	    echo -e "\033[0;31m[ERROR] couldn't push git tags.";                        \
	    echo -e "You MUST push the tag manually on commit $(BUILD_GIT_SHA)\033[0m"; \
	    exit 1;                                                                     \
	fi;

.PHONY: push_docker_tag
push_docker_tag: ## push to docker repo


# inputs cleared after including this file:
# BGB_BINARY
# BGB_GO_FLAGS
# BGB_PKG_IN_REPO
# BGB_ADDITIONAL_GO_ENV

# inputs left alone:
# DEPSDIR
# DEPSGENTOOL
# GOPATH
# GO_ENV
# MAKEFILE_LIST
# REPO_PATH

_BGB_TMP_PATH_ ?= $(lastword $(MAKEFILE_LIST))

ifeq ($(_BGB_PATH_),)

_BGB_RKT_SYMLINK_NAME_ := $(GOPATH)/src/$(REPO_PATH)

$(call setup-custom-stamp-file,_BGB_RKT_SYMLINK_STAMP_,$(_BGB_TMP_PATH_)/rkt-symlink)

$(_BGB_RKT_SYMLINK_STAMP_): | $(_BGB_RKT_SYMLINK_NAME_)
	touch "$@"

INSTALL_SYMLINKS += $(MK_TOPLEVEL_ABS_SRCDIR):$(_BGB_RKT_SYMLINK_NAME_)
CREATE_DIRS += $(call to-dir,$(_BGB_RKT_SYMLINK_NAME_))

_BGB_RKT_SYMLINK_NAME_ :=

endif

_BGB_PATH_ := $(_BGB_TMP_PATH_)

_BGB_PKG_NAME_ := $(REPO_PATH)/$(BGB_PKG_IN_REPO)

$(call setup-dep-file,_BGB_DEPMK,$(_BGB_PKG_NAME_))

# Do not depend on depsgen when we are building depsgen. Also, when
# building depsgen, it will be built first as depsgen.tmp, which in
# turn will be run to get the dependencies and then it will be renamed
# to depsgen.
ifeq ($(BGB_BINARY),$(DEPSGENTOOL))

_BGB_DEPSGEN_SUFFIX_ := .tmp

else

$(BGB_BINARY): $(DEPSGENTOOL_STAMP)

endif

-include $(_BGB_DEPMK)
$(BGB_BINARY): BGB_ADDITIONAL_GO_ENV := $(BGB_ADDITIONAL_GO_ENV)
$(BGB_BINARY): GO_ENV := $(GO_ENV)
$(BGB_BINARY): GO := $(GO)
$(BGB_BINARY): BGB_GO_FLAGS := $(BGB_GO_FLAGS)
$(BGB_BINARY): _BGB_PKG_NAME_ := $(_BGB_PKG_NAME_)
$(BGB_BINARY): DEPSGENTOOL := $(DEPSGENTOOL)
$(BGB_BINARY): _BGB_DEPSGEN_SUFFIX_ := $(_BGB_DEPSGEN_SUFFIX_)
$(BGB_BINARY): REPO_PATH := $(REPO_PATH)
$(BGB_BINARY): BGB_PKG_IN_REPO := $(BGB_PKG_IN_REPO)
$(BGB_BINARY): _BGB_DEPMK := $(_BGB_DEPMK)
$(BGB_BINARY): $(_BGB_PATH_) $(_BGB_RKT_SYMLINK_STAMP_) | $(DEPSDIR)
	set -e; \
	$(BGB_ADDITIONAL_GO_ENV) $(GO_ENV) "$(GO)" build -o "$@.tmp" $(BGB_GO_FLAGS) "$(_BGB_PKG_NAME_)"; \
	$(GO_ENV) "$(DEPSGENTOOL)$(_BGB_DEPSGEN_SUFFIX_)" go --repo "$(REPO_PATH)" --module "$(BGB_PKG_IN_REPO)" --target '$$(BGB_BINARY)' >"$(_BGB_DEPMK)"; \
	mv "$@.tmp" "$@"

BGB_PKG_IN_REPO :=
BGB_BINARY :=
BGB_GO_FLAGS :=
BGB_ADDITIONAL_GO_ENV :=
_BGB_PKG_NAME_ :=
_BGB_DEPMK :=
_BGB_DEPSGEN_SUFFIX_ :=
# _BGB_RKT_SYMLINK_STAMP_ deliberately not cleared

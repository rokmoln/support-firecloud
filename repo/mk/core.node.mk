# ------------------------------------------------------------------------------

# makefile-folder node_modules exebutables
PATH_NPM := $(MAKE_PATH)/node_modules/.bin
# repository node_modules executables
PATH_NPM := $(PATH_NPM):$(GIT_ROOT)/node_modules/.bin

define npm-which
$(shell \
	export PATH="$(PATH_NPM):$(PATH)"; \
	export RESULT="$$(for CMD in $(2); do $(WHICH_Q) $${CMD} && break || continue; done)"; \
	echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

NODE = $(call which,NODE,node)
NODE_ESM = $(call which,NODE_ESM,node-esm)
NODE_NPM = $(shell $(REALPATH) $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npm/")
NODE_NPX = $(shell $(REALPATH) $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npx/")
NPM = $(call which,NPM,npm)
NPX = $(call which,NPX,npx)
$(foreach VAR,NODE NODE_ESM NODE_NPM NODE_NPX NPM NPX,$(call make-lazy,$(VAR)))

# ------------------------------------------------------------------------------

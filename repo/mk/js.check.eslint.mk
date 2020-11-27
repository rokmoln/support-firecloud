# Adds a 'check-eslint' target to run 'eslint'
# over SF_ESLINT_FILES (defaults to all committed and staged *.js and *.ts files,
# as well as executable files with a shebang that mentiones 'node').
# The 'check-eslint' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The eslint executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the eslint executable can be changed via ESLINT_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_ESLINT_FILES_IGNORE:
# SF_ESLINT_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED ?= false

ESLINT = $(call npm-which,ESLINT,eslint)
$(foreach VAR,ESLINT,$(call make-lazy,$(VAR)))

ESLINT_ARGS += \
	--ignore-pattern '!.babelrc.js' \
	--ignore-pattern '!.eslintrc.js' \

SF_ESLINT_FILES_IGNORE += \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_ESLINT_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\.\(js\|ts\)$$" | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_ESLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g") \
	$(shell $(GIT_LS) . | while read FILE; do \
		[[ ! -L "$${FILE}" ]] || continue; \
		[[ -f "$${FILE}" ]] || continue; \
		[[ -x "$${FILE}" ]] || continue; \
		$(HEAD) -n1 "$${FILE}" | $(GREP) "^#\!/" | $(GREP) -q -e "\bnode\b" || continue; \
		$(ECHO) "'$${FILE}'"; \
	done)

SF_CHECK_TARGETS += \
	check-eslint \

# ------------------------------------------------------------------------------

.PHONY: check-eslint
check-eslint:
	SF_ESLINT_FILES_TMP=($(SF_ESLINT_FILES)); \
	[[ "$${#SF_ESLINT_FILES_TMP[@]}" = "0" ]] || { \
		$(ESLINT) $(ESLINT_ARGS) $${SF_ESLINT_FILES_TMP[@]} || { \
			$(ESLINT) $(ESLINT_ARGS) --fix $${SF_ESLINT_FILES_TMP[@]} 2>/dev/null >&2; \
			exit 1; \
		}; \
	}

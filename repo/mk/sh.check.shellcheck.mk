# Adds a 'check-shellcheck' target to run 'shellcheck'
# over SF_SHELLCHECK_FILES (defaults to all committed and staged *.sh files,
# as well as executable files with a shebang that mentiones 'bash' or 'sh').
# The 'check-shellcheck' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The shellcheck executable is lazy-found inside $PATH.
# The arguments to the shellcheck executable can be changed via SHELLCHECK_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_SHELLCHECK_FILES_IGNORE:
# SF_SHELLCHECK_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED ?= false

SHELLCHECK = $(call npm-which,SHELLCHECK,shellcheck)
$(foreach VAR,SHELLCHECK,$(call make-lazy,$(VAR)))

SHELLCHECK_ARGS += \

SF_SHELLCHECK_FILES_IGNORE += \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_SHELLCHECK_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\.sh$$" | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_SHELLCHECK_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g") \
	$(shell $(GIT_LS) . | while read FILE; do \
		[[ ! -L "$${FILE}" ]] || continue; \
		[[ -f "$${FILE}" ]] || continue; \
		[[ -x "$${FILE}" ]] || continue; \
		$(HEAD) -n1 "$${FILE}" | $(GREP) "\#" | $(GREP) -q -e "\b\(bash\|sh\)\b" || continue; \
		$(ECHO) "'$${FILE}'"; \
	done)

SF_CHECK_TARGETS += \
	check-shellcheck \

# ------------------------------------------------------------------------------

.PHONY: check-shellcheck
check-shellcheck:
	SF_SHELLCHECK_FILES_TMP=($(SF_SHELLCHECK_FILES)); \
	echo $${SF_SHELLCHECK_FILES_TMP[@]}; \
	[[ "$${#SF_SHELLCHECK_FILES_TMP[@]}" = "0" ]] || { \
		$(SHELLCHECK) $(SHELLCHECK_ARGS) $${SF_SHELLCHECK_FILES_TMP[@]}; \
	}

# Symlinks '.git/info/exclude' to support-firecloud 'gitconfig/dot.gitignore_global'
#
# '.git/info/exclude' is automatically added to the 'deps' target via SF_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------

ifneq (,$(wildcard .git))
SF_DEPS_TARGETS += \
	.git/info/exclude \

endif

# ------------------------------------------------------------------------------

.PHONY: .git/info/exclude
.git/info/exclude: $(SUPPORT_FIRECLOUD_DIR)/gitconfig/dot.gitignore_global
	$(MKDIR) $$(dirname $@)
	[[ -f $@ ]] && $(CAT) $@ 2>/dev/null | $(GREP) -v -e "^#" -e "^\s\+$$"| $(GREP) -q "^." || \
			$(LN) -sf $< $@

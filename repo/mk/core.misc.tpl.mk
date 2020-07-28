# Add a 'sf-generate-from-template' function to generate files from "template" files.
# E.g. .vscode/settings.json from .vscode/settings.json.tpl
# where the latter is an executable that outputs the content of the former.
#
# SF_CHECK_TPL_FILES += some/file.json.tpl
#
# some/file.json: some/file.json.tpl; $(call sf-generate-from-template)
#
# You can now add 'some/file.json' or the entire $(SF_CHECK_TPL_FILES)
# as an individual target's dependency, or as an additional entry to SF_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------
#
# Adds a 'check-tpl-files' that will make sure that the generated files are not dirty.
# The 'check-tpl-files' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# This is useful as part of a 'git push' with the vanilla pre-push hook,
# which will force a 'git push' to fail if the generated files are not in sync with the template ones.
#
# ------------------------------------------------------------------------------

SF_CHECK_TPL_FILES += \

define sf-generate-from-template
	$(info $@ $< $(REALPATH))
	$(shell $(ECHO_DO) "Generating $@ from template $<...")
	$(shell $(shell $(REALPATH) $<) > $@)
	$(shell $(ECHO_DONE))
endef

SF_CHECK_TARGETS += \
	check-tpl-files \

# ------------------------------------------------------------------------------

#	.vscode/settings.json: .vscode/settings.json.tpl
#		$(call generate-from-template,$<,$@)


.PHONY: check-tpl-files
check-tpl-files:
	$(MAKE) $(SF_CHECK_TPL_FILES)
	$(GIT) diff --exit-code $(SF_CHECK_TPL_FILES) || { \
		$(ECHO_ERR) "Some template-generated files have uncommitted changes."; \
		exit 1; \
	}

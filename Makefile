ifeq (,$(wildcard support-firecloud/Makefile))
INSTALL_SUPPORT_FIRECLOUD := $(shell ln -s . support-firecloud)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_SUPPORT_FIRECLOUD
endif
endif

include support-firecloud/repo/mk/generic.common.mk
include support-firecloud/repo/mk/js.deps.npm.mk
include support-firecloud/repo/mk/js.check.eslint.mk
include support-firecloud/repo/mk/core.misc.release.tag.mk

# ------------------------------------------------------------------------------

COMMON_MKS := $(wildcard repo/mk/*.common.mk)

SF_CLEAN_FILES += \
	support-firecloud \

SF_PATH_FILES_IGNORE += \
	-e "^generic/dot\.gitattributes_global$$" \
	-e "^generic/dot\.gitignore_global$$" \
	-e "^generic/dot\.gitignore_global\.base$$" \
	-e "^repo/AUTHORS$$" \
	-e "^repo/Brewfile.inc.sh$$" \
	-e "^repo/cfn/tpl\.Makefile$$" \
	-e "^repo/dot.github/" \
	-e "^repo/LICENSE$$" \
	-e "^repo/NOTICE$$" \
	-e "^repo/UNLICENSE$$" \

SF_ECLINT_FILES_IGNORE += \
	-e "^bin/" \
	-e "^generic/dot.gitignore_global$$" \
	-e "^generic/dot.gitignore_global.base$$" \
	-e "^repo/LICENSE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^support-firecloud$$" \

SF_CHECK_TPL_FILES += \
	.github/workflows/main.yml \
	.github/workflows/main.windows.yml \

SF_DEPS_TARGETS += \
	.github/workflows/main.yml \
	.github/workflows/main.windows.yml \

SF_TEST_TARGETS += \
	test-secret \
	test-upload-job-artifacts \
	test-repo-mk \

GITHUB_GLOBAL_GITIGNORE_BASE_URL := https://raw.githubusercontent.com/github/gitignore/master/Global

GITHUB_GLOBAL_GITIGNORES := \
	Backup \
	Diff \
	Emacs \
	Linux \
	Patch \
	Vim \
	VisualStudioCode \
	Windows \
	macOS \

GITHUB_GLOBAL_GITIGNORES := $(patsubst %,generic/github-global-gitignore/%.gitignore,$(GITHUB_GLOBAL_GITIGNORES))

# ------------------------------------------------------------------------------

.github/workflows/main.yml: .github/workflows/main.yml.tpl .github/workflows.src/main.yml
	$(call sf-generate-from-template)


.github/workflows/main.windows.yml: .github/workflows/main.windows.yml.tpl .github/workflows.src/main.windows.yml
	$(call sf-generate-from-template)


.PHONY: test-secret
test-secret:
ifeq ($(SF_IS_TRANSCRYPTED),true)
	$(CAT) doc/how-to-manage-secrets.md.test.secret
	$(CAT) doc/how-to-manage-secrets.md.test.secret | \
		$(GREP) -q "This is a test of transcrypt."
else
	:
endif


.PHONY: test-upload-job-artifacts
test-upload-job-artifacts:
	$(ECHO) "This is a test of upload-job-artifacts" >some-job-artifact.md


.PHONY: test-repo-mk
test-repo-mk:
	$(MAKE) help
	for mk in $(COMMON_MKS); do \
		$(ECHO_DO) "Testing $${mk}..."; \
		$(MAKE) -f repo/mk/generic.common.mk -f $${mk} help; \
		$(ECHO_DONE); \
	done


generic/github-global-gitignore/%.gitignore:
	$(CURL) -o $@ $(GITHUB_GLOBAL_GITIGNORE_BASE_URL)/$*.gitignore


.PHONY: generic/dot.gitignore_global
generic/dot.gitignore_global: $(GITHUB_GLOBAL_GITIGNORES) ## Regenerate generic/dot.gitignore_global.
	$(ECHO) -e "\n# BEGIN $@.base\n" > $@
	$(CAT) $@.base >> $@
	$(ECHO) -e "\n# END $@.base\n" >> $@
	for GITHUB_GLOBAL_GITIGNORE in $(GITHUB_GLOBAL_GITIGNORES); do \
		$(ECHO) -e "################################################################################" >> $@; \
		$(ECHO) -e "\n# BEGIN $(GITHUB_GLOBAL_GITIGNORE_BASE_URL)/$${GITHUB_GLOBAL_GITIGNORE}.gitignore\n" >> $@; \
		$(CAT) $${GITHUB_GLOBAL_GITIGNORE} >> $@; \
		$(ECHO) -e "\n# END $(GITHUB_GLOBAL_GITIGNORE_BASE_URL)/$${GITHUB_GLOBAL_GITIGNORE}.gitignore\n" >> $@; \
	done

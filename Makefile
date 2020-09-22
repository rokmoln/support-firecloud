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

BREW = $(call which,BREW,brew)
$(foreach VAR,BREW,$(call make-lazy,$(VAR)))

COMMON_MKS := $(wildcard repo/mk/*.common.mk)

FORMULA_PATCH_FILES := $(shell $(GIT_LS) "Formula/*.patch")
FORMULA_PATCHED_FILES := $(patsubst %.original.rb,%.rb,$(shell $(GIT_LS) "Formula/patch-src/*.original.rb"))

SF_CLEAN_FILES += \
	support-firecloud \

SF_VENDOR_FILES_IGNORE += \
	-e "^Formula/.*\.patch$$" \
	-e "^Formula/patch-src/" \

SF_PATH_FILES_IGNORE += \
	-e "^Formula/" \
	-e "^generic/dot\.gitattributes_global$$" \
	-e "^generic/dot\.gitignore_global$$" \
	-e "^generic/dot\.gitignore_global\.base$$" \
	-e "^generic/dot\.gitignore_global\.tpl$$" \
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
	generic/dot.gitignore_global \
	$(FORMULA_PATCH_FILES) \
	$(FORMULA_PATCHED_FILES) \

SF_DEPS_TARGETS += \
	.github/workflows/main.yml \

SF_TEST_TARGETS += \
	test-secret \
	test-upload-job-artifacts \
	test-repo-mk \

# ------------------------------------------------------------------------------

.github/workflows/main.yml: .github/workflows/main.yml.tpl .github/workflows.src/main.yml
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


generic/dot.gitignore_global: generic/dot.gitignore_global.tpl generic/dot.gitignore_global.base ## Regenerate generic/dot.gitignore_global.
	$(call sf-generate-from-template)


.PHONY: Formula/patch-src/%.original.rb
Formula/patch-src/%.original.rb:
	# see https://discourse.brew.sh/t/how-to-tap-homebrew-linuxbrew-core-on-macos/8731/3
	if [[ "$(OS_SHORT)" = "darwin" ]]; then \
		$(CURL) -q -fsSL https://raw.githubusercontent.com/homebrew/linuxbrew-core/master/Formula/$*.rb -o $@; \
	else \
		$(BREW) cat $* > $@; \
	fi
	if [[ -f Formula/$*.linux.patch ]]; then \
		$(MAKE) Formula/patch-src/$*.rb || { \
			$(ECHO_ERR) "Failed to apply old patch Formula/$*.linux.patch and update patched file Formula/patch-src/$*.rb."; \
			exit 1; \
		} \
	else \
		$(CP) Formula/patch-src/$*.original.rb Formula/patch-src/$*.rb; \
	fi
	$(EDITOR) Formula/patch-src/$*.rb
	$(MAKE) Formula/$*.linux.patch


.PHONY: Formula/%.linux.patch
Formula/%.linux.patch: Formula/patch-src/%.original.rb
	$(call sf-generate-from-template-patch,Formula/patch-src/$*.rb)


.PHONY: Formula/patch-src/%.rb
Formula/patch-src/%.rb: Formula/patch-src/%.original.rb
	$(call sf-generate-from-template-patched,Formula/$*.linux.patch)

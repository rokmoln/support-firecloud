# ------------------------------------------------------------------------------

SF_DEPS_TARGETS += \
	deps-channels \

# ------------------------------------------------------------------------------

.PHONY: deps-channels
deps-channels: guard-env-SF_PROMOTE_EXTERNAL_GIT_URL guard-env-SF_PROMOTE_CHANNELS
	$(ECHO_DO) "Cloning $(SF_PROMOTE_EXTERNAL_GIT_URL) into $(SF_PROMOTE_EXTERNAL_DIR)..."
	$(GIT) check-ignore $(SF_PROMOTE_EXTERNAL_DIR) || { \
		$(ECHO_ERR) "$(SF_PROMOTE_EXTERNAL_DIR) should be ignored by git."; \
		$(ECHO_INFO) "Please add '/$(SF_PROMOTE_EXTERNAL_DIR)' to the repository's .gitignore ."; \
		exit 1; \
	}
	$(RM) $(SF_PROMOTE_EXTERNAL_DIR)
	$(GIT) clone $(SF_PROMOTE_EXTERNAL_GIT_URL) $(SF_PROMOTE_EXTERNAL_DIR)
	cd $(SF_PROMOTE_EXTERNAL_DIR) && { \
		$(LN) -s $(SUPPORT_FIRECLOUD_DIR) support-firecloud; \
		$(GIT) check-ignore support-firecloud || $(ECHO) "/support-firecloud" >> .gitignore; \
		$(RM) Makefile; \
		$(ECHO) "include support-firecloud/repo/mk/core.common.mk" >> Makefile; \
		$(ECHO) "include support-firecloud/repo/mk/channels.common.mk" >> Makefile; \
		$(ECHO) "SF_PROMOTE_CHANNELS := $(SF_PROMOTE_CHANNELS)" >> Makefile; \
		$(GIT) check-ignore Makefile || $(ECHO) "/Makefile" >> .gitignore; \
	}
	$(ECHO_DONE)

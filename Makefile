.SUFFIXES : .txt

# GENERIC VARIABLES
#
CAT=                         	cat
CUT=                            cut
ECHO=                           echo
GREP=                           grep
MERGE_LINES=                    tr '\n' ' '
SED=                            sed
UNIQ=                           sort -u

OMNIMARK=                       omnimark

ROOT_DIR=                    	$(shell pwd)

DEPS_SUFFIX=       	     	.mki
XOM_SUFFIX=                     .xom
XVC_SUFFIX=			.xvc
TXT_SUFFIX=                     .txt
XMD_SUFFIX=                     .xmd

# DIRECTORIES
#
COMMAND_LINE_DIRECTORY=         command-line
COMMON_DIRECTORY=               common
EBNF_DIRECTORY=                 ebnf
GRAMMAR_DIRECTORY=              grammar
LL_DIRECTORY=                   ll
LR_DIRECTORY=                   lr

MESSAGES_DIRECTORY=             messages

# EXECUTABLES
#
WRAPPER=			$(COMMAND_LINE_DIRECTORY)/wrapper$(XVC_SUFFIX)
MESSAGES_GENERATE=              $(MESSAGES_DIRECTORY)/generate$(XOM_SUFFIX)

# FILES
#
DEPS_MAKEFILES=                 $(subst $(XVC_SUFFIX),$(DEPS_SUFFIX),$(WRAPPER))

MESSAGES_FILE_NAMES=            $(addsuffix $(addsuffix $(TXT_SUFFIX), messages),           \
					    $(COMMAND_LINE_DIRECTORY)/ $(COMMON_DIRECTORY)/ \
					    $(EBNF_DIRECTORY)/ $(GRAMMAR_DIRECTORY)/        \
					    $(LR_DIRECTORY)/)
MESSAGES_MODULE_NAMES=          $(subst $(TXT_SUFFIX),$(XMD_SUFFIX),$(MESSAGES_FILE_NAMES))

.PHONY : wrapper messages clean

# RULES
#
all :: wrapper messages


wrapper : $(WRAPPER)


messages $(WRAPPER) : $(MESSAGES_MODULE_NAMES)


clean ::
	$(RM) $(WRAPPER) $(MESSAGES_MODULE_NAMES) $(DEPS_MAKEFILES)


# SUFFIX RULES
#
%$(XVC_SUFFIX) : %$(XOM_SUFFIX)
	$(OMNIMARK) -s $< -save $@ -depend $(call MAKE_DEPS_FILENAME, $@).tmp
	$(ECHO) "$@ $(call MAKE_DEPS_FILENAME, $@) : $< " | $(MERGE_LINES) > $(call MAKE_DEPS_FILENAME, $@)
	$(CAT) $(call MAKE_DEPS_FILENAME, $@).tmp          \
		| $(CUT) -f4 -d'"' | $(GREP) "$(ROOT_DIR)" \
		| $(UNIQ)                                  \
		| $(SED) 's%$(ROOT_DIR)/%%g'               \
		| $(MERGE_LINES) >> $(call MAKE_DEPS_FILENAME, $@)
	$(RM) $(call MAKE_DEPS_FILENAME, $@).tmp


%$(XMD_SUFFIX) : %$(TXT_SUFFIX)
	$(OMNIMARK) -s $(MESSAGES_GENERATE) $< > $@


# FUNCTIONS
#
MAKE_DEPS_FILENAME=$(addsuffix $(DEPS_SUFFIX),$(basename $(1)))


# INCLUDES
#
-include $(DEPS_MAKEFILES)

#
#  There exist several targets which are by default empty and which can be 
#  used for execution of your targets. These targets are usually executed 
#  before and after some main targets. They are: 
#
#     .build-pre:              called before 'build' target
#     .build-post:             called after 'build' target
#     .clean-pre:              called before 'clean' target
#     .clean-post:             called after 'clean' target
#     .clobber-pre:            called before 'clobber' target
#     .clobber-post:           called after 'clobber' target
#     .all-pre:                called before 'all' target
#     .all-post:               called after 'all' target
#     .help-pre:               called before 'help' target
#     .help-post:              called after 'help' target
#
#  Targets beginning with '.' are not intended to be called on their own.
#
#  Main targets can be executed directly, and they are:
#  
#     build                    build a specific configuration
#     clean                    remove built files from a configuration
#     clobber                  remove all built files
#     all                      build all configurations
#     help                     print help mesage
#  
#  Targets .build-impl, .clean-impl, .clobber-impl, .all-impl, and
#  .help-impl are implemented in nbproject/makefile-impl.mk.
#
#  Available make variables:
#
#     CND_BASEDIR                base directory for relative paths
#     CND_DISTDIR                default top distribution directory (build artifacts)
#     CND_BUILDDIR               default top build directory (object files, ...)
#     CONF                       name of current configuration
#     CND_ARTIFACT_DIR_${CONF}   directory of build artifact (current configuration)
#     CND_ARTIFACT_NAME_${CONF}  name of build artifact (current configuration)
#     CND_ARTIFACT_PATH_${CONF}  path to build artifact (current configuration)
#     CND_PACKAGE_DIR_${CONF}    directory of package (current configuration)
#     CND_PACKAGE_NAME_${CONF}   name of package (current configuration)
#     CND_PACKAGE_PATH_${CONF}   path to package (current configuration)
#
# NOCDDL


# Environment 
MKDIR=mkdir
CP=cp
CCADMIN=CCadmin
RANLIB=ranlib

GIT_VERSION := $(shell git describe --abbrev=4 --dirty --always 2>/dev/null || echo unknown)
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)

# String macros for C (replaces fragile -D quoting in generated nbproject rules).
MP_EXTRA_CC_PRE += -DREPOVERSION=\"$(GIT_VERSION)\" -DREPOBRANCH=\"$(GIT_BRANCH)\"
# Size: default MPLAB rules use -g without -O; full newlib + app overflows 128 KB flash without this.
# (-Os is XC32 PRO-only; -O2 is the practical free-tier choice here.)
MP_EXTRA_CC_PRE += -O2 -ffunction-sections -fdata-sections
# Legacy libmchp_peripheral is MIPS32; app rules used -mips16 — interlink kept for any mixed objects.
MP_EXTRA_CC_PRE += -minterlink-mips16
MP_EXTRA_LD_PRE += -minterlink-mips16
# Calls into the large legacy peripheral archive need indirect calls (R_MIPS_26 truncation otherwise).
MP_EXTRA_CC_PRE += -mlong-calls

# Legacy PLIB: MPLAB X regenerates nbproject/Makefile-default.mk — this keeps <plib.h> on the include path anyway.
MP_EXTRA_CC_PRE := -I$(CURDIR)/third_party/pic32mx-legacy-plib/include $(MP_EXTRA_CC_PRE)

# PLIB archive must follow all app .o on the linker command line (see nbproject
# Makefile-default.mk link rules). Do not pass it only inside -Wl,... — symbols
# can remain at VMA 0 and every PORT* call faults.
#
# XC32 v5 + legacy libmchp_peripheral: some .text.<PLIBfunc> sections from the
# .a can land at VMA 0 and stay outside the kseg0 PT_LOAD segment (see
# xc32-readelf -l / -S) while the symbol still resolves to 0 — calls fault.
# --whole-archive around the full .a pulls too much and hit R_MIPS_26 truncation
# here; prefer avoiding those PLIB entry points (SFR/inline) or a supported lib.

# build
build: .build-post

.build-pre:
# Add your pre 'build' code here...

.build-post: .build-impl
# Add your post 'build' code here...


# clean
clean: .clean-post

.clean-pre:
# Add your pre 'clean' code here...
# WARNING: the IDE does not call this target since it takes a long time to
# simply run make. Instead, the IDE removes the configuration directories
# under build and dist directly without calling make.
# This target is left here so people can do a clean when running a clean
# outside the IDE.

.clean-post: .clean-impl
# Add your post 'clean' code here...


# clobber
clobber: .clobber-post

.clobber-pre:
# Add your pre 'clobber' code here...

.clobber-post: .clobber-impl
# Add your post 'clobber' code here...


# all
all: .all-post

.all-pre:
# Add your pre 'all' code here...

.all-post: .all-impl
# Add your post 'all' code here...


# help
help: .help-post

.help-pre:
# Add your pre 'help' code here...

.help-post: .help-impl
# Add your post 'help' code here...



# include project implementation makefile
include nbproject/Makefile-impl.mk

# include project make variables
include nbproject/Makefile-variables.mk

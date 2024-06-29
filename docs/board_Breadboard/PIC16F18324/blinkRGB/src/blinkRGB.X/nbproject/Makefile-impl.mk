#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a pre- and a post- target defined where you can add customization code.
#
# This makefile implements macros and targets common to all configurations.
#
# NOCDDL


# Building and Cleaning subprojects are done by default, but can be controlled with the SUB
# macro. If SUB=no, subprojects will not be built or cleaned. The following macro
# statements set BUILD_SUB-CONF and CLEAN_SUB-CONF to .build-reqprojects-conf
# and .clean-reqprojects-conf unless SUB has the value 'no'
SUB_no=NO
SUBPROJECTS=${SUB_${SUB}}
BUILD_SUBPROJECTS_=.build-subprojects
BUILD_SUBPROJECTS_NO=
BUILD_SUBPROJECTS=${BUILD_SUBPROJECTS_${SUBPROJECTS}}
CLEAN_SUBPROJECTS_=.clean-subprojects
CLEAN_SUBPROJECTS_NO=
CLEAN_SUBPROJECTS=${CLEAN_SUBPROJECTS_${SUBPROJECTS}}


# Project Name
PROJECTNAME=blinkRGB.X

# Active Configuration
DEFAULTCONF=18F67J60
CONF=${DEFAULTCONF}

# All Configurations
ALLCONFS=16F18324 16F18855 18F47K40 16F1619 16F1788 18F27K40 18F46J50 18F67J94 16F886 18F4580 18F26K80 18F67J60 


# build
.build-impl: .build-pre
	${MAKE} -f nbproject/Makefile-${CONF}.mk SUBPROJECTS=${SUBPROJECTS} .build-conf


# clean
.clean-impl: .clean-pre
	${MAKE} -f nbproject/Makefile-${CONF}.mk SUBPROJECTS=${SUBPROJECTS} .clean-conf

# clobber
.clobber-impl: .clobber-pre .depcheck-impl
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F18324 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F18855 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F47K40 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F1619 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F1788 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F27K40 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F46J50 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F67J94 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F886 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F4580 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F26K80 clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F67J60 clean



# all
.all-impl: .all-pre .depcheck-impl
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F18324 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F18855 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F47K40 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F1619 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F1788 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F27K40 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F46J50 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F67J94 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=16F886 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F4580 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F26K80 build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=18F67J60 build



# dependency checking support
.depcheck-impl:
#	@echo "# This code depends on make tool being used" >.dep.inc
#	@if [ -n "${MAKE_VERSION}" ]; then \
#	    echo "DEPFILES=\$$(wildcard \$$(addsuffix .d, \$${OBJECTFILES}))" >>.dep.inc; \
#	    echo "ifneq (\$${DEPFILES},)" >>.dep.inc; \
#	    echo "include \$${DEPFILES}" >>.dep.inc; \
#	    echo "endif" >>.dep.inc; \
#	else \
#	    echo ".KEEP_STATE:" >>.dep.inc; \
#	    echo ".KEEP_STATE_FILE:.make.state.\$${CONF}" >>.dep.inc; \
#	fi

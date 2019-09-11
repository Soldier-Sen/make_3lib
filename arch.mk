ROOT_PATH    = $(shell pwd)


ARCH ?=
CROSS ?= 
ifeq ($(ARCH), gk710x)
	CROSS=arm-goke-linux-uclibcgnueabi-
	HOST_NAME=arm-linux
	
else ifeq ($(ARCH), gk720x)
	CROSS=arm-gk720x-linux-uclibcgnueabi-
	HOST_NAME=arm-linux	
	
else ifeq ($(ARCH), mstart)
	CROSS=arm-buildroot-linux-uclibcgnueabi-

else ifeq ($(ARCH),hi3518ev200) 
	CROSS=arm-hisiv300-linux-
else ifeq ($(ARCH),himix200)
	CROSS=arm-himix200-linux-
else ifeq ($(ARCH),)
	ifeq ($(shell uname -m), x86_64)
		ARCH=x64
	endif	

endif


CC=$(CROSS)gcc
CXX=$(CROSS)g++
AR=$(CROSS)ar
STRIP=$(CROSS)strip

INSTALL_TOP=$(ROOT_PATH)/install/$(ARCH)

export INSTALL_DIR=$INSTALL_TOP
export ARCH CROSS CC CXX AR STRIP

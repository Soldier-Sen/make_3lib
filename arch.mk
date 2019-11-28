ROOT_PATH    = $(shell pwd)


arch ?=
CROSS ?= 
ifeq ($(arch), gk710x)
	CROSS=arm-goke-linux-uclibcgnueabi-
	HOST_NAME=arm-linux
	
else ifeq ($(arch), gk720x)
	CROSS=arm-gk720x-linux-uclibcgnueabi-
	HOST_NAME=arm-linux	
	
else ifeq ($(arch), mstart)
	CROSS=arm-buildroot-linux-uclibcgnueabihf-

else ifeq ($(arch),hi3518ev200) 
	CROSS=arm-hisiv300-linux-
else ifeq ($(arch),himix200)
	CROSS=arm-himix200-linux-
else ifeq ($(arch),)
	ifeq ($(shell uname -m), x86_64)
		arch=x64
	endif	

endif


CC=$(CROSS)gcc
CXX=$(CROSS)g++
AR=$(CROSS)ar
STRIP=$(CROSS)strip

INSTALL_TOP=$(ROOT_PATH)/install/$(arch)

export INSTALL_DIR=$INSTALL_TOP
export arch CROSS CC CXX AR STRIP

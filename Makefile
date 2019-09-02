include ./arch.mk

SUPPORT_BUILD_MBEDTLS=y
SUPPORT_BUILD_CJSON=y
SUPPORT_BUILD_ICONV=y
SUPPORT_BUILD_LIBUUID=y
SUPPORT_BUILD_LIBJPEG=y
SUPPORT_BUILD_HOSTAP=n
SUPPORT_BUILD_LOG4C=n
SUPPORT_BUILD_WPA_SUPPORT=n
SUPPORT_BUILD_LOG4C=n
SUPPORT_BUILD_CURL=n
SUPPORT_BUILD_OPUS=n
SUPPORT_BUILD_OPENSSL=y

all: mbedtls cjson iconv libuuid opus wpa hostapd openssl 
.PHONY:all
	@echo -e "\033[0;1;32mbuild $(ARCH) platform lib\033[0m"

### libuuid
libuuid:
ifeq ($(SUPPORT_BUILD_LIBUUID),y)
ifneq ($(shell [ -f $(INSTALL_TOP)/libuuid/lib/libuuid.a ] && echo y),y)
	mkdir -p $(INSTALL_TOP)/libuuid
	tar xf libuuid-1.0.3.tar.gz
	cd libuuid-1.0.3 && ./configure --prefix=$(INSTALL_TOP)/libuuid  --host=${HOST_NAME} --enable-shared=no --enable-static=yes CC=$(CC) && make -j4 && make install && cd -
	rm -rf libuuid-1.0.3
endif
	@echo -e "\033[0;1;32mlibuuid already build OK\033[0m"
endif


### mbedtls
mbedtls:
ifeq ($(SUPPORT_BUILD_MBEDTLS),y)
ifneq ($(shell [ -f $(INSTALL_TOP)/mbedtls/lib/libmbedtls.a ] && echo y),y)
		mkdir -p $(INSTALL_TOP)/mbedtls
		rm -fr mbedtls-2.12.0
		tar xf mbedtls-2.12.0-apache.tgz
		cd mbedtls-2.12.0 && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=$(INSTALL_TOP)/mbedtls && make -j4 && make install && cd ../../
		rm -fr mbedtls-2.12.0
endif
	@echo -e "\033[0;1;32mmbedtls already build OK\033[0m"
endif

#### cjson
cjson:
ifeq ($(SUPPORT_BUILD_CJSON),y)
ifneq ($(shell [ -f ${INSTALL_TOP}/cjson/lib/libcjson.a ] && echo y),y)
	mkdir -p $(INSTALL_TOP)/cjson
	unzip cJSON.zip > /dev/null
	cd cJSON && make CC=$(CC) -j4 &&  make install PREFIX=${INSTALL_TOP}/cjson && cd -
	rm -fr cJSON
endif
	@echo -e "\033[0;1;32mcjson already build OK\033[0m"
endif

#### iconv: 
iconv:
ifeq ($(SUPPORT_BUILD_ICONV),y)
ifneq ($(shell [ -f ${INSTALL_TOP}/iconv/lib/libconv.a] && echo y),y)
	mkdir -p $(INSTALL_TOP)/iconv
	tar xf libiconv-1.15.tar.gz
	cd libiconv-1.15 && ./configure --prefix=${INSTALL_TOP}/iconv --host=${HOST_NAME} --enable-static=yes --enable-shared=no CC=$(CC) && make -j4 && make install && cd -
	rm -rf libiconv-1.15	
endif
	@echo -e "\033[0;1;32miconv already build OK\033[0m"
endif



openssl:
ifeq (0,0)
	@echo "start decompress openssl"
	rm -rf $(LOCAL_PREBUILD_DIR)/openssl/openssl_install
	mkdir $(LOCAL_PREBUILD_DIR)/openssl/openssl_code -p
	mkdir $(LOCAL_PREBUILD_DIR)/openssl/openssl_install -p
ifneq ($(shell  [ -d $(LOCAL_PREBUILD_DIR)/openssl/openssl_code/openssl-1.0.2h ] && echo y),y)
	tar zxvf $(SRCROOT)/third_lib/openssl-1.0.2h/openssl-1.0.2h.tar.gz -C $(LOCAL_PREBUILD_DIR)/openssl/openssl_code
	@echo "decompress openssl complete"

	cd $(LOCAL_PREBUILD_DIR)/openssl/openssl_code/openssl-1.0.2h && setarch i386 ./config no-asm -shared --prefix=$(LOCAL_PREBUILD_DIR)/openssl/openssl_install

	for i in $(SRCROOT)/third_lib/openssl-1.0.2h/patch/*.patch; do\
		if [ -f "$$i" ];then\
			echo -e " patches found in $$i";\
			cd $(LOCAL_PREBUILD_DIR)/openssl/openssl_code/openssl-1.0.2h;\
			patch -p0 <p0$$i;\
		fi;\
	done

	for i in $(SRCROOT)/third_lib/openssl-1.0.2h/patch/crypto/*.patch; do\
		if [ -f "$$i" ];then\
			echo -e " patches found in $$i";\
			cd $(LOCAL_PREBUILD_DIR)/openssl/openssl_code/openssl-1.0.2h/crypto;\
			patch -p0 <p0$$i;\
		fi;\
	done
else
	@echo "=====openssl already exist======"
endif
	cd $(LOCAL_PREBUILD_DIR)/openssl/openssl_code/openssl-1.0.2h && make -j16 CC=$(CC) AR=$(AR) AR+=r RANLIB=$(RANLIB) && make install CC=$(CC)
#CCcd $(LOCAL_PREBUILD_DIR)/openssl/openssl_install/lib && chmod 777 lib*.so* && $(STRIP) -s lib*.so*
	cd $(LOCAL_PREBUILD_DIR)/openssl/openssl_install/lib && rm libcrypto.so* -rf && rm libssl.so* -rf
endif

#### opus ####	
opus: 
ifeq (0,0)	
	@echo "start decompress opus"
	rm -rf mkdir $(LOCAL_PREBUILD_DIR)/opus/opus_install
	mkdir $(LOCAL_PREBUILD_DIR)/opus/opus_code -p
	mkdir $(LOCAL_PREBUILD_DIR)/opus/opus_install	-p
ifneq ($(shell  [ -d $(LOCAL_PREBUILD_DIR)/opus/opus_code/opus-1.2.1 ] && echo y),y)
	tar zxvf $(ROOT_PATH)/third_lib/opus-1.2.1/opus-1.2.1.tar.tar -C $(LOCAL_PREBUILD_DIR)/opus/opus_code
	@echo "tar opus complete"
	
	cd $(LOCAL_PREBUILD_DIR)/opus/opus_code/opus-1.2.1 && ./configure --prefix=$(LOCAL_PREBUILD_DIR)/opus/opus_install --disable-doc CC=$(CC) --host=$(HOST_NAME) CFLAGS="-Os" --enable-fixed-point --enable-intrinsics 
	
	for i in $(ROOT_PATH)/third_lib/opus-1.2.1/patch/*.patch; do\
		if [ -f "$$i" ];then\
			echo -e " patches found in $$i";\
			cd $(LOCAL_PREBUILD_DIR)/opus/opus_code/opus-1.2.1;\
			patch -p0 <	$$i;\
		fi;\
	done
else
	@echo "=====opus already exist======"
endif	
	cd $(LOCAL_PREBUILD_DIR)/opus/opus_code/opus-1.2.1 && make -j8 && make install
	cd $(LOCAL_PREBUILD_DIR)/opus/opus_install/lib && rm libopus.so* -rf
endif	

#libnl
libnl:
ifeq (0,0)
	@echo "start decompress libnl"
	rm -rf mkdir $(LOCAL_PREBUILD_DIR)/libnl/libnl_install
	mkdir -p $(LOCAL_PREBUILD_DIR)/libnl/libnl_code
	mkdir -p $(LOCAL_PREBUILD_DIR)/libnl/libnl_install
ifneq ($(shell  [ -d $(LOCAL_PREBUILD_DIR)/libnl/libnl_code/libnl-1.1.4 ] && echo y),y)
	tar zxvf $(ROOT_PATH)/third_lib/libnl/libnl-1.1.4.tar.gz -C $(LOCAL_PREBUILD_DIR)/libnl/libnl_code
	@echo "tar libnl complete"
else
	@echo "=====libnl already exist======"
endif
	cd $(LOCAL_PREBUILD_DIR)/libnl/libnl_code/libnl-1.1.4 && ./configure --prefix=$(LOCAL_PREBUILD_DIR)/libnl/libnl_install 
	cd $(LOCAL_PREBUILD_DIR)/libnl/libnl_code/libnl-1.1.4 && make CC=$(CC) && make install
	cd $(LOCAL_PREBUILD_DIR)/libnl/libnl_install/lib && $(STRIP) -s lib*.so*
endif	


#wpa_supplicant
wpa: 
ifeq (0,0)
	@echo "start decompress wpa_supplicant"
	rm -rf mkdir $(LOCAL_PREBUILD_DIR)/wpa/wpa_install
	mkdir -p $(LOCAL_PREBUILD_DIR)/wpa/wpa_code
	mkdir -p $(LOCAL_PREBUILD_DIR)/wpa/wpa_install
ifneq ($(shell  [ -d $(LOCAL_PREBUILD_DIR)/wpa/wpa_code/wpa_supplicant-2.6 ] && echo y),y)
	tar zxvf $(ROOT_PATH)/third_lib/wpa/wpa_supplicant-2.6.tar.gz -C $(LOCAL_PREBUILD_DIR)/wpa/wpa_code
	cp $(ROOT_PATH)/third_lib/wpa/patch/*.patch $(LOCAL_PREBUILD_DIR)/wpa/wpa_code/wpa_supplicant-2.6 
	cp $(ROOT_PATH)/third_lib/wpa/mypatch.sh $(LOCAL_PREBUILD_DIR)/wpa/wpa_code/wpa_supplicant-2.6 
	cd $(LOCAL_PREBUILD_DIR)/wpa/wpa_code/wpa_supplicant-2.6/ && ./mypatch.sh; cd wpa_supplicant
	cd $(LOCAL_PREBUILD_DIR)/wpa/wpa_code/wpa_supplicant-2.6/wpa_supplicant && sed -i 's/#CONFIG_AP=y/CONFIG_AP=y/g' defconfig && cp defconfig .config
	@echo "tar wpa_supplicant complete"
else
	@echo "=====wpa_supplicant already exist======"
endif
	cd $(LOCAL_PREBUILD_DIR)/wpa/wpa_code/wpa_supplicant-2.6/wpa_supplicant && make CC=$(CC) EXTRA_CFLAGS="-I$(LOCAL_PREBUILD_DIR)/openssl/openssl_install/include -I$(LOCAL_PREBUILD_DIR)/libnl/libnl_install/include" LIBS="-L$(LOCAL_PREBUILD_DIR)/openssl/openssl_install/lib -lssl -lcrypto -ldl -L$(LOCAL_PREBUILD_DIR)/libnl/libnl_install/lib -lnl" -j4 && make install DESTDIR=$(LOCAL_PREBUILD_DIR)/wpa/wpa_install 
	$(STRIP) -s $(LOCAL_PREBUILD_DIR)/wpa/wpa_install/usr/local/sbin/wpa*
endif	
#wpa_supplicant
hostapd: 
ifeq (0,0)
	@echo "start decompress hostapd-2.6"
	rm -rf mkdir $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_install
	mkdir -p $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_code
	mkdir -p $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_install
ifneq ($(shell  [ -d $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_code/hostapd-2.6 ] && echo y),y)
	tar xf $(ROOT_PATH)/third_lib/hostapd/hostapd-2.6.tar.gz -C $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_code
	cd $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_code/hostapd-2.6/hostapd && cp defconfig .config && sed -i 's/#CONFIG_IEEE80211N=y/CONFIG_IEEE80211N=y/g' .config
	cd $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_code/hostapd-2.6/hostapd
	@echo "tar hostapd-2.6 complete"
else
	@echo "=====hostapd already exist======"
endif
	cd $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_code/hostapd-2.6/hostapd && make CC=$(CC) EXTRA_CFLAGS="-I$(LOCAL_PREBUILD_DIR)/openssl/openssl_install/include -I$(LOCAL_PREBUILD_DIR)/libnl/libnl_install/include" LIBS="-L$(LOCAL_PREBUILD_DIR)/openssl/openssl_install/lib -lssl -lcrypto -ldl -L$(LOCAL_PREBUILD_DIR)/libnl/libnl_install/lib -lnl" && make install DESTDIR=$(LOCAL_PREBUILD_DIR)/hostapd/hostapd_install 
	$(STRIP) -s $(LOCAL_PREBUILD_DIR)/hostapd/hostapd_install/usr/local/bin/hostapd*
endif	
.PHONY: clean clean_lib clean_all
clean_all:

clean:

clean_lib:
	rm -rf 	$(LOCAL_PREBUILD_DIR)
	
.PHONY: cjson 
.PHONY: curl
.PHONY: srtp  
.PHONY: mdns 
.PHONY: openssl 
.PHONY: opus 

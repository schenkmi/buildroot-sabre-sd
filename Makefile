BUILDROOT_DIR=$(PWD)

BUILDROOT_VERSION=2018.08.2
BUILDROOT_TGZ=buildroot-$(BUILDROOT_VERSION).tar.bz2
BUILDROOT_SRC_DIR=$(BUILDROOT_DIR)/buildroot-$(BUILDROOT_VERSION)
BUILDROOT_INSTALL_DIR=$(BUILDROOT_SRC_DIR)/output
LOCAL_NAME=$(BUILDROOT_TGZ)

BUILDROOT_PATCH_LIST=


BUILDROOT_TC_TAG=toolchain-rpi2
BUILDROOT_TC_DIR=$(BUILDROOT_DIR)/$(BUILDROOT_TC_TAG)

BUILDROOTCFG=sabre-sd.config.$(BUILDROOT_VERSION)
BUILDROOT_TC_TAG=toolchain-sabre-sd
BUILDROOT_TC_DIR=$(BUILDROOT_DIR)/$(BUILDROOT_TC_TAG)



all: config build install

patchbuildroot:
	@for p in  $(BUILDROOT_PATCH_LIST); 			\
	do 												\
	echo "--> apply patch $$p" ; 					\
	cd $(BUILDROOT_SRC_DIR) && patch -p1 < $$p ; 	\
	done

config:
	@echo === configure $(LOCAL_NAME) =============================================
	test -d $(BUILDROOT_SRC_DIR) || (cd $(BUILDROOT_DIR) && tar xjvf $(BUILDROOT_TGZ) && $(MAKE) patchbuildroot)
	test -e $(BUILDROOT_SRC_DIR)/.config || (cd $(BUILDROOT_DIR) && cp $(BUILDROOTCFG) $(BUILDROOT_SRC_DIR)/.config && cd $(BUILDROOT_SRC_DIR) && make oldconfig)
	@echo === successful configured $(LOCAL_NAME) =================================

build:
	@echo === build $(LOCAL_NAME) =============================================
	cd $(BUILDROOT_SRC_DIR) && make
	@echo === build $(LOCAL_NAME) =============================================

.PHONY : install
install:
	@echo === install $(LOCAL_NAME) ===============================================
	test ! -d $(BUILDROOT_TC_DIR) || rm -rf $(BUILDROOT_TC_DIR)
	install -d -m 775 $(BUILDROOT_TC_DIR)
	cp -af $(BUILDROOT_SRC_DIR)/output/host $(BUILDROOT_TC_DIR)
	cp -af $(BUILDROOT_SRC_DIR)/output/images $(BUILDROOT_TC_DIR)
	cp -af $(BUILDROOT_SRC_DIR)/output/target $(BUILDROOT_TC_DIR)
	test ! -d $(BUILDROOT_SRC_DIR)/output/legal-info || cp -af $(BUILDROOT_SRC_DIR)/output/legal-info $(BUILDROOT_TC_DIR)
	cd $(BUILDROOT_TC_DIR) && ln -s $(BUILDROOT_TC_DIR)/host/usr/arm-buildroot-linux-gnueabihf/sysroot/ staging
	cd $(BUILDROOT_TC_DIR) && find . -type d -empty -exec touch {}/.gitignore \;
	
	# As we work with a toolhchain directory we need to adapt any *.la pathes
	@for F in `find $(BUILDROOT_TC_DIR) -type f -name *.la`; do								\
	     echo "Process: $$F"; 																\
         sed -i -e "s/buildroot-${BUILDROOT_VERSION}\/output/${BUILDROOT_TC_TAG}/g" "$$F"; 	\
	done
	@echo === successful installed $(LOCAL_NAME) ==================================

.PHONY: clean
clean:
	cd $(BUILDROOT_SRC_DIR) && make clean

.PHONY: distclean
distclean:
	test ! -d $(BUILDROOT_SRC_DIR) || rm -rf $(BUILDROOT_SRC_DIR)


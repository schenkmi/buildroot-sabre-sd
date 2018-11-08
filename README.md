# buildroot-sabre-sd

This is a lightweight Linux system with all essential tools needed to flash a Android 8 into the SABRE SD eMMC.

## Clone

```
https://github.com/schenkmi/buildroot-sabre-sd.git
```

## Build

```
cd buildroot-sabre-sd
make config
make build
make install
```

## Install to SD Card

Be aware that your data on this card will be toasted and do a careful check the SD cards device name.
```
sudo dd bs=1M status=progress if=toolchain-sabre-sd/images/sdcard.img of=/dev/sdX
```
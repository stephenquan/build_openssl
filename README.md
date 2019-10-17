# build_openssl_ios

Bash script for building OpenSSL development libraries for iOS.

This requires an Internet connection and the latest Xcode installed.
It downloads OpenSSL source code and builds iOS fat library containing iphoneos (arm64) and iphonesimulator (x86_64) targets.

## Building

To build OpenSSL for iOS:

```bash
./build_openssl_ios.sh
```

This will create `~/openssl/ios/include` and `~/openssl/ios/lib` folders.

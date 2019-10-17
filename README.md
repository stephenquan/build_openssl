# build_openssl

Bash script for building OpenSSL development libraries for iOS and macOS.

This requires an Internet connection and the latest Xcode installed.
It downloads OpenSSL source code and builds iOS fat library containing iphoneos (arm64) and iphonesimulator (x86_64) targets.

## Building

To build OpenSSL for iOS:

```bash
./build_openssl_ios.sh
```

This will create `~/openssl/ios` with `include` and `lib` folders.

To build OpenSSL for macOS:

```bash
./build_openssl_macos.sh
```

This will create `/openssl/macos` with `bin`, `include`, `lib`, `share` and `ssl` folders.

## Usage

These libraries can be used in your iOS and macOS applications requiring OpenSSL.

To compile your C++ with OpenSSL, be sure to add the appropriate openssl folder to your
include path, i.e.

For iOS: `-I${HOME}/openssl/ios/include`
For macOS: `-I${HOME}/openssl/macos/include`

For linking, be sure to add the appropriate openssl folder to your libraries search
path, i.e.

For iOS: `-L${HOME}/openssl/ios/lib -lcrypto -lssl`
For macOS: `-L${HOME}/openssl/macos/lib -lcrypto -lssl`

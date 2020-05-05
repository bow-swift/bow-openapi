// nef:begin:header
/*
 layout: docs
 title: Installation guide
 */
// nef:end
/*:
 # Installation guide

 Bow OpenAPI is compatible with Unix systems.

 ## 💻 OS X users

 Bow OpenAPI is available via [Homebrew](https://brew.sh/). If you still don't have it installed in your Mac, you can follow the steps in [this link](https://brew.sh/) to set it up.

 Once you have it, you need to run the following commands:

 ```bash
 brew tap bow-swift/bow
 brew install bow-openapi
 ```

 Bow OpenAPI depends on the tool `swagger-codegen`; if you do not have it installed, Homebrew will install this package prior to installing Bow OpenAPI.

 ## 🐧 Linux users

 ```bash
 curl -s https://api.github.com/repos/bow-swift/bow-openapi/releases/latest \
 | grep -oP '"tag_name": "\K(.*)(?=")' \
 | xargs -I {} wget -O - https://github.com/bow-swift/bow-openapi/archive/{}.tar.gz \
 | tar xz \
 && cd bow-openapi-* \
 && sudo make linux
 ```

 > It will install the last stable version.

 Bow OpenAPI depends on `Java 8+` and `swagger-codegen`; both will be installed from `Makefile`. After the installation, you can type `bow-openapi -h` in a new terminal to use it.

 */

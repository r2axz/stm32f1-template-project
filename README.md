# stm32f1-template-project

stm32f1-template-project is a Makefile based template for stm32f1 projects.

Currently it's configured to support stm32f103c8t6 MCU found on
the "Blue Pill" boards. Switching to another MCU or MCU series should be
fairly straightforward.

## Prerequisites

Install the following software:

- [arm-none-eabi toolchain](
    https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
- [open source stlink](<https://github.com/texane/stlink>)
- [STM32CubeF1](
    <https://www.st.com/en/embedded-software/stm32cubef1.html>)

ARM toolchain, stlink, and must be added to PATH (use ~/.bash_profile).
Assuming everything is installed in ~/stm32/:

```bash
# add ARM toolchain path
export PATH=~/stm32/gcc-arm-none-eabi/bin:$PATH
# add stlink path
export PATH=~/stm32/stlink-install/bin:$PATH
```

Path to STM32CubeF1 should be also exported (use ~/.bash_profile):

```bash
# export STM32Cube
export STM32CUBE_PATH=~/stm32/stm32cube
```

## Building Project

Run

```bash
make
```

to build the project and create the firmware hex file.

Run

```bash
make flash
```

to flash MCU using st-link.

Run

```bash
make clean
```

To remove object and dependency files.

Run

```bash
make distclean
```

to remove object, dependency, and firmware files.

## Note on Linker Script

Currently the Makefile uses STM32F103XB_FLASH.ld, which defines 128K flash size.
However, stm32f103c8t6 has 64K flash. Make sure firmware fits MCU memory.

## Hardware Documentation

- [STM32F103C8T6 Datasheet](
    https://www.st.com/resource/en/datasheet/stm32f103c8.pdf)
- [STM32F103C8T6 Reference Manual](
    https://www.st.com/content/ccc/resource/technical/document/reference_manual/59/b9/ba/7f/11/af/43/d5/CD00171190.pdf/files/CD00171190.pdf/jcr:content/translations/en.CD00171190.pdf)
- [Cortex-M3 Devices Generic User Guide](
    http://infocenter.arm.com/help/topic/com.arm.doc.dui0552a/DUI0552A_cortex_m3_dgug.pdf)
- [Nokia 5110 Display Controller Datasheet](
    https://www.sparkfun.com/datasheets/LCD/Monochrome/Nokia5110.pdf)

## Continuous Integration (CI)

The project pipeline consists of the following stages:

- __lint__ for performing style checks on source and documentation files;
- __analyze__ to run static code analysis on project source files;
- __build__ to build the project;

### Lint Stage

The job of the __lint__ is to make sure that source code and documentation
formatting remains consistent. It contains the following jobs:

#### Markdown Lint

__markdown lint__ job checks all markdown files with [markdownlint-cli](
    https://www.npmjs.com/package/markdownlint-cli).

It performs very similar checks to what [VSCode markdownlint](
    https://github.com/DavidAnson/vscode-markdownlint) does.
As long as you use the default settings and have no issues with your
markdown in __VSCode__ you should be fine.

#### Clang-format Check

This job makes sure all C source and headers files have consistent formatting
according to the coding style provided in _.clang-format_ configuration file
in the root directory of the project.

You can reformat your files with [Clang-Format](
    https://marketplace.visualstudio.com/items?itemName=xaver.clang-format)
__VSCode__ extension. You should have __clang-format__ binary installed in your
system.

The default settings should be just fine.

__NOTE:__ __clang-format__ version should be 8.0.0 or above.
Please don't use clang-format that comes from the Ubuntu 18.04 packages
repository as it contains a severely outdated version.

See [Step 3: Install Clang-Format](#step-3-install-clang-format)
for Ubuntu 18.04 installation instructions.

Install 8 version of __clang-format__ from <https://apt.llvm.org> instead.

### Analyze Stage

This stage contains a single job to run static code analysis on source files
listed in the SRCS variable of the Makefile.

The __cppcheck job__ uses __cppcheck__ with the following options:

```bash
    cppcheck --enable=all --error-exitcode=1
```

### Build Stage

The __build stage__ contans a single job to build the project.
It outputs the firmware binary in the Intel HEX format with the following name:

```yml
$CI_PROJECT_NAME-$CI_COMMIT_REF_NAME-$CI_COMMIT_SHORT_SHA.hex
```

### Configuring GitLab Runner on Ubuntu 18.04

#### Step 1: Install And Register GitLab Runner

```bash
curl -L https://packages.gitlab.com/\
install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
cat <<EOF | sudo tee /etc/apt/preferences.d/pin-gitlab-runner.pref
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF
sudo apt-get install gitlab-runner
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner register
```

Set tags to: "__stm32, linux__" when registering the runner.

#### Step 2: Install Markdown Linter

```bash
sudo npm install -g markdownlint-cli
```

#### Step 3: Install Clang-Format

This installs __clang-format__ from <https://apt.llvm.org>.

```bash
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo add-apt-repository\
'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-8 main'
sudo apt install clang-format-8
sudo ln -s /usr/bin/clang-format-8 /usr/bin/clang-format
```

#### Step 4: Install Cppcheck

```bash
sudo apt install cppcheck
```

#### Step 5: Install ARM Toolchain

```bash
sudo su -l gitlab-runner
mkdir -p stm32 && cd stm32
wget --content-disposition https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2019q3/RC1.1/gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2?revision=c34d758a-be0c-476e-a2de-af8c6e16a8a2?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,8-2019-q3-update
tar xjf gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2
ln -s gcc-arm-none-eabi-8-2019-q3-update gcc-arm-none-eabi
```

#### Step 6: Install STM32CubeF1

Note: adjust this section if you use another MCU series.

Download [STM32CubeF1](
    <https://www.st.com/en/embedded-software/stm32cubef1.html>)
and copy __en.stm32cubef1.zip__ to __/home/gitlab-runner/stm32__.

```bash
unzip en.stm32cubef1.zip
ln -s STM32Cube_FW_F1_V1.8.0 stm32cube
```

#### Step 7: Set up Environment Variables

```bash
cat <<EOF | tee -a /home/gitlab-runner/.profile
# set PATH to gcc-arm-none-eabi if it exists
if [ -d "\$HOME/stm32/gcc-arm-none-eabi/bin" ] ; then
    PATH="\$HOME/stm32/gcc-arm-none-eabi/bin:\$PATH"
fi

# set PATH to stm32cube if it exists
if [ -d "\$HOME/stm32/stm32cube" ] ; then
    STM32CUBE_PATH="\$HOME/stm32/stm32cube"
    export STM32CUBE_PATH
fi
EOF
```

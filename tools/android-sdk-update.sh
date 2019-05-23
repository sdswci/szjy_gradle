#!/bin/bash
mkdir -p /opt/android-sdk-linux/.gradle
mkdir -p /opt/android-sdk-linux/bin/
cp /opt/tools/android-env.sh /opt/android-sdk-linux/bin/
source /opt/android-sdk-linux/bin/android-env.sh

built_in_sdk=1

if [ $# -ge 0 ] && [ "$1" == "lazy-dl" ]
then
    echo "Using Lazy Download Flavour"
    built_in_sdk=0
elif [ $# -ge 0 ] && [ "$1" == "built-in" ]
then
    echo "Using Built-In SDK Flavour"
    built_in_sdk=1
else
    echo "Please use either built-in or lazy-dl as parameter"
    exit 1
fi

cd ${ANDROID_HOME}
echo "Set ANDROID_HOME to ${ANDROID_HOME}"

if [ -f sdk-tools-linux.zip ]
then
  echo "SDK Tools already bootstrapped. Skipping initial setup"
else
  echo "Bootstrapping SDK-Tools"
  wget -q http://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -O sdk-tools-linux.zip
  unzip sdk-tools-linux.zip
  rm -f sdk-tool-linux.zip
fi

echo "Make sure repositories.cfg exists"
mkdir -p ~/.android/
touch ~/.android/repositories.cfg

echo "Copying Licences"
cp -rv /opt/licenses ${ANDROID_HOME}/licenses

echo "Copying Tools"
mkdir -p ${ANDROID_HOME}/bin
cp -v /opt/tools/*.sh ${ANDROID_HOME}/bin

echo "Installing packages"
if [ $built_in_sdk -eq 1 ]
then
    android-accept-licenses.sh "sdkmanager ${SDKMNGR_OPTS} --package_file=/opt/tools/package-list-minimal.txt --verbose"
else
    android-accept-licenses.sh "sdkmanager ${SDKMNGR_OPTS} --package_file=/opt/tools/package-list.txt --verbose"
fi

echo "Updating SDK"
update_sdk

echo "Accepting Licenses"
android-accept-licenses.sh "sdkmanager ${SDKMNGR_OPTS} --licenses --verbose"


android-accept-licenses.sh "sdkmanager 'extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0'"
echo "update gradle bins"
cd ${ANDROID_HOME}

gradle_bin="https://services.gradle.org/distributions/gradle-4.5.1-bin.zip"
sha_list=("5bla5rpoe2f27tgp94vclhpsok"  "a5vbgfvpwtoqz8v2cdivxz28k")

#.gradle/wrapper/dists/gradle-3.5-bin/daoimhu7k5rlo48ntmxw2ok3e/gradle-3.5-bin.zip
GFNAME=${gradle_bin##*/} #filename:[gradle-4.4-bin.zip]
GBASE=${GFNAME%.zip} 
fpath=".gradle/wrapper/dists/${GBASE}/${sha_list[0]}"
fname="${fpath}/${GFNAME}"
echo "Target: ${fname}"
echo "Downloading $gradle_bin"
mkdir -p ${fpath}
pushd ${fpath} 
wget --no-check-certificate ${gradle_bin}
cd ..
ln -s ${sha_list[0]} ${sha_list[1]}
popd


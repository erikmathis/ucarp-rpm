#!/bin/bash

CWD=$(pwd)
VERSION="1.5.2"
SPEC="files/ucarp.spec"
SOURCE_URL="https://github.com/jsumners/UCarp.git"

which git > /dev/null
if [ $? -ne 0 ]; then
  echo "Aborting. Cannot continue without git."
  exit 1
fi

which rpmbuild > /dev/null
if [ $? -ne 0 ]; then
  echo "Aborting. Cannot continue without rpmbuild from the rpm-build package."
  exit 1
fi

echo "Creating RPM build path structure..."
mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS,tmp}

cp files/ucarp.spec rpmbuild/SPECS/
cp files/* rpmbuild/SOURCES/

echo "Downloading sources..."
cd rpmbuild/SOURCES
if [ ! -d ucarp-${VERSION} ]; then
  git clone https://github.com/jsumners/UCarp.git ucarp-${VERSION}
  cd ucarp-${VERSION}
  git checkout pidfile
  cd ..
fi

if [ -d ucarp-${VERSION} ]; then
  cd ucarp-${VERSION}
  git checkout pidfile
  cd ..
  echo "Tarring source tree..."
  tar cf - ucarp-${VERSION} > ucarp-${VERSION}.tar
fi

if [ -f ${CWD}/gpg-env ]; then
  echo "Building RPM with GPG signing..."
  cd ${CWD}

  source gpg-env
  if [ "${gpg_bin}" != "" ]; then
    rpmbuild --define "_topdir ${CWD}/rpmbuild" \
      --define "_signature ${signature}" \
      --define "_gpg_path ${gpg_path}" --define "_gpg_name ${gpg_name}" \
      --define "__gpg ${gpg_bin}" --sign -ba ${SPEC}
  else
    rpmbuild --define "_topdir ${CWD}/rpmbuild" \
      --define "_signature ${signature}" \
      --define "_gpg_path ${gpg_path}" --define "_gpg_name ${gpg_name}" \
      --sign --ba ${SPEC}
  fi
else
  echo "Building RPM..."
  cd ${CWD}
  rpmbuild --define "_topdir ${CWD}/rpmbuild" --ba ${SPEC}
fi


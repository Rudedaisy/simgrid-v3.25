#!/usr/bin/env sh

set -e

BUILDFOLDER=$WORKSPACE/build

die() {
    echo "$@"
    exit 1
}

### Check the node installation

pkg_check() {
  for pkg
  do
    if command -v $pkg
    then
       echo "$pkg is installed. Good."
    else
       die "please install $pkg before proceeding"
    fi
  done
}

pkg_check xsltproc gcovr ant cover2cover.py

### Cleanup previous runs

! [ -z "$WORKSPACE" ] || die "No WORKSPACE"
[ -d "$WORKSPACE" ] || die "WORKSPACE ($WORKSPACE) does not exist"

do_cleanup() {
  for d
  do
    if [ -d "$d" ]
    then
      rm -rf "$d" || die "Could not remove $d"
    fi
    mkdir "$d" || die "Could not create $d"
  done
}

do_cleanup "$BUILDFOLDER"

NUMPROC="$(nproc)" || NUMPROC=1


cd $BUILDFOLDER
rm -rf java_cov*
rm -rf jacoco_cov*
rm -rf python_cov*
rm -rf xml_coverage.xml

ctest -D ExperimentalStart || true

cmake -Denable_documentation=OFF -Denable_lua=ON \
      -Denable_compile_optimizations=OFF -Denable_compile_warnings=ON \
      -Denable_jedule=ON -Denable_mallocators=ON \
      -Denable_smpi=ON -Denable_smpi_MPICH3_testsuite=ON -Denable_model-checking=ON \
      -Denable_smpi_papi=ON \
      -Denable_memcheck=OFF -Denable_memcheck_xml=OFF -Denable_smpi_ISP_testsuite=ON -Denable_coverage=ON $WORKSPACE

#build with sonarqube scanner wrapper
/home/ci/build-wrapper-linux-x86/build-wrapper-linux-x86-64 --out-dir bw-outputs make -j$NUMPROC tests
JACOCO_PATH="/usr/local/share/jacoco"
export JAVA_TOOL_OPTIONS="-javaagent:${JACOCO_PATH}/lib/jacocoagent.jar"

export PYTHON_TOOL_OPTIONS="/usr/bin/python3-coverage run --parallel-mode --branch"

ctest --no-compress-output -D ExperimentalTest -j$NUMPROC || true
ctest -D ExperimentalCoverage || true

unset JAVA_TOOL_OPTIONS
if [ -f Testing/TAG ] ; then

  files=$( find . -size +1c -name "jacoco.exec" )
  i=0
  for file in $files
  do
    sourcepath=$( dirname $file )
    #convert jacoco reports in xml ones
    ant -f $WORKSPACE/tools/jenkins/jacoco.xml -Dexamplesrcdir=$WORKSPACE -Dbuilddir=$BUILDFOLDER/${sourcepath} -Djarfile=$BUILDFOLDER/simgrid.jar -Djacocodir=${JACOCO_PATH}/lib
    #convert jacoco xml reports in cobertura xml reports
    cover2cover.py $BUILDFOLDER/${sourcepath}/report.xml .. ../src/bindings/java src/bindings/java > $BUILDFOLDER/java_coverage_${i}.xml
    #save jacoco xml report as sonar only allows it 
    mv $BUILDFOLDER/${sourcepath}/report.xml $BUILDFOLDER/jacoco_cov_${i}.xml
    i=$((i + 1))
  done

  #convert python coverage reports in xml ones
  cd $BUILDFOLDER
  find .. -size +1c -name ".coverage*" -exec mv {} . \;
  /usr/bin/python3-coverage combine
  /usr/bin/python3-coverage xml -i -o ./python_coverage.xml

   cd $WORKSPACE
   #convert all gcov reports to xml cobertura reports
   gcovr -r . --xml-pretty -e teshsuite -u -o $BUILDFOLDER/xml_coverage.xml
   xsltproc $WORKSPACE/tools/jenkins/ctest2junit.xsl build/Testing/$( head -n 1 < build/Testing/TAG )/Test.xml > CTestResults_memcheck.xml

   #generate sloccount report
   sloccount --duplicates --wide --details $WORKSPACE | grep -v -e '.git' -e 'mpich3-test' -e 'sloccount.sc' -e 'isp/umpire' -e 'build/' -e 'xml_coverage.xml' -e 'CTestResults_memcheck.xml' -e 'DynamicAnalysis.xml' > $WORKSPACE/sloccount.sc

fi || exit 42

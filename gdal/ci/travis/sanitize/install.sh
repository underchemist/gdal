#!/bin/sh

set -e

export ASAN_OPTIONS=allocator_may_return_null=1 

cd gdal
export CCACHE_CPP2=yes

ccache -M 1G
ccache -s

# build proj
curl http://download.osgeo.org/proj/proj-4.9.3.tar.gz > proj-4.9.3.tar.gz
tar xvzf proj-4.9.3.tar.gz
cd proj-4.9.3/nad
curl http://download.osgeo.org/proj/proj-datumgrid-1.5.tar.gz > proj-datumgrid-1.5.tar.gz
tar xvzf proj-datumgrid-1.5.tar.gz
cd ..
CC="ccache gcc" CXX="ccache g++ " ./configure --prefix=/usr
make -j3
sudo make install
cd ..

sudo ldconfig
ls -al /usr/lib/libproj*

CPPFLAGS="-DMAKE_SANITIZE_HAPPY -fsanitize=undefined -fsanitize=address" LDFLAGS="-fsanitize=undefined -fsanitize=address" ./configure --prefix=/usr --without-libtool --enable-debug --with-jpeg12 --with-poppler --without-podofo --with-spatialite --with-mysql --with-liblzma --with-webp --with-epsilon --with-libtiff=internal --with-rename-internal-libtiff-symbols --with-hide-internal-symbols --with-gnm --with-fgdb=$PWD/../FileGDB_API-64gcc51
make USER_DEFS="-Werror" -j3
cd apps
make USER_DEFS="-Werror" test_ogrsf
cd ..
cd swig/python
CPPFLAGS="-fsanitize=undefined -fsanitize=address" python setup.py build
cd ../..
#cd swig/java
#cat java.opt | sed "s/JAVA_HOME =.*/JAVA_HOME = \/usr\/lib\/jvm\/java-7-openjdk-amd64\//" > java.opt.tmp
#mv java.opt.tmp java.opt
#make
#cd ../..
#cd swig/perl
#make generate
#make
#cd ../..
sudo rm -f /usr/lib/libgdal.so*
sudo make install
cd swig/python
sudo python setup.py install
cd ../..
sudo ldconfig
#g++ -Wall -DDEBUG -fPIC -g ogr/ogrsf_frmts/null/ogrnulldriver.cpp  -shared -o ogr_NULL.so -L. -lgdal -Iport -Igcore -Iogr -Iogr/ogrsf_frmts
#GDAL_DRIVER_PATH=$PWD ogr2ogr -f null null ../autotest/ogr/data/poly.shp
cd ../autotest/cpp
make -j3
cd ../../gdal
#wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mdb-sqlite/mdb-sqlite-1.0.2.tar.bz2
#tar xjvf mdb-sqlite-1.0.2.tar.bz2
#sudo cp mdb-sqlite-1.0.2/lib/*.jar /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/ext

ccache -s
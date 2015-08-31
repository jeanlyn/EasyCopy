#!/usr/bin/env bash

FWDIR="$(cd "`dirname $0`"; pwd)"

DISTDIR="$FWDIR/dist"

MVN=$MAVEN_HOME/bin/mvn
if [ ! $(command -v "$MVN") ] ; then
    echo -e "Could not locate Maven command: '$MVN'."
    echo -e "Please specify the '$MAVEN_HOME' !"
    exit -1;
fi

rm -rf $DISTDIR

mkdir -p $DISTDIR/data


cp -r $FWDIR/bin $DISTDIR
cp -r $FWDIR/conf $DISTDIR
cp $FWDIR/target/*.jar $DISTDIR/bin

TARDIR_NAME="tableInfoGetter-bin"
TARDIR=$FWDIR/$TARDIR_NAME

cp -r $DISTDIR $TARDIR

tar cvf ${TARDIR_NAME}.tar.gz -C $FWDIR $TARDIR_NAME

rm -rf $TARDIR
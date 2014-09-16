VERSIONSTRING=$($FWDIR/sbt/sbt "show version")

if [ $? == -1 ] ;then
    echo -e "You need sbt installed and available on your path."
    echo -e "Download sbt from http://www.scala-sbt.org/"
    exit -1;
fi

VERSION=$(echo "${VERSIONSTRING}" | tail -1 | cut -f 2 | sed 's/^\([a-zA-Z0-9.-]*\).*/\1/')
echo "Version is ${VERSION}"

# Initialize defaults
SPARK_HADOOP_VERSION=1.0.4
SPARK_YARN=false
MAKE_TGZ=false

# Parse arguments
while (( "$#" )); do
  case $1 in
    --hadoop)
      SPARK_HADOOP_VERSION="$2"
      shift
      ;;
    --with-yarn)
      SPARK_YARN=true
      ;;
    --tgz)
      MAKE_TGZ=true
      ;;
  esac
  shift
done

if [ "$MAKE_TGZ" == "true" ]; then
  echo "Making spark-$VERSION-hadoop_$SPARK_HADOOP_VERSION-bin.tar.gz"
else
  echo "Making distribution for Spark $VERSION in $DISTDIR..."
fi

echo "Hadoop version set to $SPARK_HADOOP_VERSION"
if [ "$SPARK_YARN" == "true" ]; then
  echo "YARN enabled"

# Build fat JAR
export SPARK_HADOOP_VERSION
export SPARK_YARN
cd $FWDIR

"sbt/sbt" "assembly/assembly"

# Make directories
rm -rf "$DISTDIR"
mkdir -p "$DISTDIR/jars"
echo "Spark $VERSION built for Hadoop $SPARK_HADOOP_VERSION" > "$DISTDIR/RELEASE"

# Copy jars
cp $FWDIR/assembly/target/scala*/*assembly*hadoop*.jar "$DISTDIR/jars/"

# Copy other things
mkdir "$DISTDIR"/conf
cp "$FWDIR"/conf/*.template "$DISTDIR"/conf
cp -r "$FWDIR/bin" "$DISTDIR"
cp -r "$FWDIR/python" "$DISTDIR"
cp -r "$FWDIR/sbin" "$DISTDIR"


if [ "$MAKE_TGZ" == "true" ]; then
  TARDIR="$FWDIR/spark-$VERSION"
  cp -r "$DISTDIR" "$TARDIR"
  tar -zcf "spark-$VERSION-hadoop_$SPARK_HADOOP_VERSION-bin.tar.gz" -C "$FWDIR" "spark-$VERSION"
  rm -rf "$TARDIR"
fi


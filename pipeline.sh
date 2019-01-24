#!/bin/bash

saxonb-xslt -s:pathways.xml -xsl:pax2mox.xsl -o:emptyfile -ext:on
for id in $(cat pathways.xml | grep "pathway id" | sed 's|.*id="\([^"]*\).*|\1|'); do
    saxonb-xslt -s:"pathway-${id}.xml" -xsl:mox2dot.xsl -o:"pathway-${id}"
    dot -Tsvg "pathway-${id}" -O
done

cat <<EOF >pathways.htm
<html>
<head><title>UCL Module Dependencies</title></head>
<body>
EOF
for id in $(cat pathways.xml | grep "pathway id" | sed 's|.*id="\([^"]*\).*|\1|'); do
    name=$(cat pathways.xml | grep "id=\"$id\"" | sed 's|.*name="\([^"]*\).*|\1|')
    echo "<h1>${name}</h1>" >> pathways.htm
    tail -n +4 "pathway-$id.svg" >> pathways.htm
done

cat <<EOF >>pathways.htm
</body>
</html>
EOF

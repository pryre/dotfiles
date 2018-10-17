for topic in $(rostopic list -b $1)
do
  topicname=$(echo $topic | tr "/" "_");
  echo "Extracting: $topicname";
  rostopic echo -p -b $1 $topic > bag$topicname.csv;
done


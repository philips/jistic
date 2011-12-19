#!/bin/bash

num_messages=2000000
message_size=200

base_dir=$(dirname $0)/../../../../

rm -rf /tmp/zookeeper
rm -rf /tmp/kafka-logs

echo "start the servers ..."
$base_dir/bin/zookeeper-server-start.sh $base_dir/config/zookeeper.properties 2>&1 > $base_dir/zookeeper.log &
$base_dir/bin/kafka-server-start.sh $base_dir/config/server.properties 2>&1 > $base_dir/kafka.log &

sleep 4
echo "start producing $num_messages messages ..."
$base_dir/bin/kafka-run-class.sh kafka.tools.ProducerPerformance --brokerinfo broker.list=0:localhost:9092 --topic test01 --messages $num_messages --message-size $message_size --batch-size 200 --threads 1 --reporting-interval 100000 num_messages --async --delay-btw-batch-ms 10

echo "wait for data to be persisted" 
cur_offset="-1"
quit=0
while [ $quit -eq 0 ]
do
  sleep 2
  target_size=`$base_dir/bin/kafka-run-class.sh kafka.tools.GetOffsetShell --server kafka://localhost:9092 --topic test01 --partition 0 --time -1 --offsets 1 | tail -1`
  if [ $target_size -eq $cur_offset ]
  then
    quit=1
  fi
  cur_offset=$target_size
done

sleep 2
actual_size=`$base_dir/bin/kafka-run-class.sh kafka.tools.GetOffsetShell --server kafka://localhost:9092 --topic test01 --partition 0 --time -1 --offsets 1 | tail -1`
msg_full_size=`expr $message_size + 9`
expected_size=`expr $num_messages \* $msg_full_size`

if [ $actual_size != $expected_size ]
then
   echo "actual size: $actual_size expected size: $expected_size test failed!!! look at it!!!"
else
   echo "test passed"
fi

ps ax | grep -i 'kafka.kafka' | grep -v grep | awk '{print $1}' | xargs kill -15 > /dev/null
sleep 2
ps ax | grep -i 'QuorumPeerMain' | grep -v grep | awk '{print $1}' | xargs kill -15 > /dev/null


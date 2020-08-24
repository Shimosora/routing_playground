# NetWork Playground v4
Network Namespace を使用してOSPFルーティングをしたときに作ったシェルスクリプトとconfigファイルのまとめです．
## NetWork Namespace
create-namespace.sh で指定された環境を作ることができます．
## Quagga ファイル
OSPFを実現する際，今回はquaggaを使用しました．
その時に書き込んだ 各zebraファイルと各OSPF configファイルをまとめておいてあります．

使用する際は，quaggaをダウンロードした後．
/etc/quagga に各zebraファイルと各OSPF configファイル を入れてください．
以下起動コマンド
```
ip netns exec R1 /usr/sbin/zebra -d -f /etc/quagga/r1-zebra.conf -i /var/run/quagga/r1-zebra.pid -A 127.0.0.1 -z /var/run/quagga/r1-zebra.vty
ip netns exec R2 /usr/sbin/zebra -d -f /etc/quagga/r2-zebra.conf -i /var/run/quagga/r2-zebra.pid -A 127.0.0.1 -z /var/run/quagga/r2-zebra.vty
ip netns exec R3 /usr/sbin/zebra -d -f /etc/quagga/r3-zebra.conf -i /var/run/quagga/r3-zebra.pid -A 127.0.0.1 -z /var/run/quagga/r3-zebra.vty

ip netns exec R1 /usr/sbin/ospfd -d -f /etc/quagga/r1-ospfd.conf -i /var/run/quagga/r1-ospfd.pid -A 127.0.0.1 -z /var/run/quagga/r1-zebra.vty
ip netns exec R2 /usr/sbin/ospfd -d -f /etc/quagga/r2-ospfd.conf -i /var/run/quagga/r2-ospfd.pid -A 127.0.0.1 -z /var/run/quagga/r2-zebra.vty
ip netns exec R3 /usr/sbin/ospfd -d -f /etc/quagga/r3-ospfd.conf -i /var/run/quagga/r3-ospfd.pid -A 127.0.0.1 -z /var/run/quagga/r3-zebra.vty
```

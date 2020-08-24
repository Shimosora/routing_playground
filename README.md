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
## 実行結果
traceroute R1>R3(10.2.0.2)

![スクリーンショット 2020-08-24 21 38 20](https://user-images.githubusercontent.com/29059240/91045968-9fbea680-e652-11ea-8418-583cdf71234f.png)

pingR1>R3(10.2.0.2)

![スクリーンショット 2020-08-24 21 37 07](https://user-images.githubusercontent.com/29059240/91046023-b533d080-e652-11ea-8ad7-c8af7da244b9.png)


# NetWork Playground SRv6
Network Namespace を使用してSRv6を動かしたときのシェルスクリプトと，SRHがついてることがわかるpcapファイルです．
## NetWork Namespace
create-namespace-SRv6.sh で指定された環境を作ることができます．
ここではHost1>>Host2へ通信をしています．
そのルーティングの中継点として，SRv6でnode1を指定しています．

### 構成図
![図1](https://user-images.githubusercontent.com/29059240/91050807-27f47a00-e65a-11ea-8663-c1c92a740cdf.png)



node1-Router2間でのキャプチャファイル画像

SRv6.pcap

![スクリーンショット 2020-08-24 20 43 55](https://user-images.githubusercontent.com/29059240/91048376-8ddf0280-e656-11ea-8263-09b02ebf87d5.png)

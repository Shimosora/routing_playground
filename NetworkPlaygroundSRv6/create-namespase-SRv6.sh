
#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then
    echo "Please run with sudo"
    exit 1
fi

run () {
    echo "$@"
    "$@" || exit 1
}

create_R1 () {
    # setup namespaces
    run ip netns add host1
    run ip netns add R1

    # setup veth peer
    run ip link add veth-h1-rt1 type veth peer name veth-rt1-h1
    run ip link set veth-h1-rt1 netns host1
    run ip link set veth-rt1-h1 netns R1

    # host1 configuraiton
    run ip netns exec host1 ip link set lo up
    run ip netns exec host1 ip addr add fc00:a::2/64 dev veth-h1-rt1
    run ip netns exec host1 ip link set veth-h1-rt1 up
    run ip netns exec host1 ip -6 route add fc00:12::/64 via fc00:a::1
    run ip netns exec host1 ip -6 route add fc00:23::/64 via fc00:a::1
    run ip netns exec host1 ip -6 route add fc00:b::/64 via fc00:a::1
    run ip netns exec host1 ip -6 route add fc00:c::/64 via fc00:a::1

    # R1 configuration
    run ip netns exec R1 ip link set lo up
    run ip netns exec R1 ip link set veth-rt1-h1 up
    run ip netns exec R1 ip addr add fc00:a::1/64 dev veth-rt1-h1

    # sysctl for R1
    ip netns exec R1 sysctl net.ipv6.conf.all.forwarding=1
    ip netns exec R1 sysctl net.ipv6.conf.all.seg6_enabled=1
}

create_R2 () {
    # setup namespaces
    run ip netns add node1
    run ip netns add R2

    # setup veth peer
    run ip link add veth-node1-rt2 type veth peer name veth-rt2-node1
    run ip link set veth-node1-rt2 netns node1
    run ip link set veth-rt2-node1 netns R2

    # node1 configuraiton
    run ip netns exec node1 ip link set lo up
    run ip netns exec node1 ip addr add fc00:b::10/64 dev veth-node1-rt2
    run ip netns exec node1 ip link set veth-node1-rt2 up
    run ip netns exec node1 ip -6 route add fc00:12::/64 via fc00:b::1
    run ip netns exec node1 ip -6 route add fc00:23::/64 via fc00:b::1
    run ip netns exec node1 ip -6 route add fc00:a::/64 via fc00:b::1
    run ip netns exec node1 ip -6 route add fc00:c::/64 via fc00:b::1

    # R2 configuration
    run ip netns exec R2 ip link set lo up
    run ip netns exec R2 ip link set veth-rt2-node1 up
    run ip netns exec R2 ip link add hostbr0 type bridge
    run ip netns exec R2 ip link set hostbr0 up
    run ip netns exec R2 ip link set dev veth-rt2-node1 master hostbr0
    run ip netns exec R2 ip addr add fc00:b::1/64 dev hostbr0

    # sysctl for R2
    ip netns exec R2 sysctl net.ipv6.conf.all.forwarding=1
    ip netns exec R2 sysctl net.ipv6.conf.all.seg6_enabled=1

    # seg6_enable for node1
    ip netns exec node1 sysctl net.ipv6.conf.all.forwarding=1
    ip netns exec node1 sysctl net.ipv6.conf.all.seg6_enabled=1
    ip netns exec node1 sysctl net.ipv6.conf.veth-node1-rt2.seg6_enabled=1
}

create_R3 () {
    # setup namespaces
    run ip netns add host2
    run ip netns add R3

    # setup veth peer
    run ip link add veth-h2-rt3 type veth peer name veth-rt3-h2
    run ip link set veth-h2-rt3 netns host2
    run ip link set veth-rt3-h2 netns R3

    # host2 configuraiton
    run ip netns exec host2 ip link set lo up
    run ip netns exec host2 ip addr add fc00:c::2/64 dev veth-h2-rt3
    run ip netns exec host2 ip link set veth-h2-rt3 up
    run ip netns exec host2 ip -6 route add fc00:12::/64 via fc00:c::1
    run ip netns exec host2 ip -6 route add fc00:23::/64 via fc00:c::1
    run ip netns exec host2 ip -6 route add fc00:a::/64 via fc00:c::1
    run ip netns exec host2 ip -6 route add fc00:b::/64 via fc00:c::1

    # R3 configuration
    run ip netns exec R3 ip link set lo up
    run ip netns exec R3 ip link set veth-rt3-h2 up
    run ip netns exec R3 ip addr add fc00:c::1/64 dev veth-rt3-h2

    # sysctl for R3
    ip netns exec R3 sysctl net.ipv6.conf.all.forwarding=1
    ip netns exec R3 sysctl net.ipv6.conf.all.seg6_enabled=1
}

connect_rt1_rt2 () {
    # create veth peer
    run ip link add veth-rt1-rt2 type veth peer name veth-rt2-rt1
    run ip link set veth-rt1-rt2 netns R1
    run ip link set veth-rt2-rt1 netns R2

    # configure R1
    run ip netns exec R1 ip link set veth-rt1-rt2 up
    run ip netns exec R1 ip addr add fc00:12::1/64 dev veth-rt1-rt2
    run ip netns exec R1 ip -6 route add fc00:b::/64 via fc00:12::2
    run ip netns exec R1 ip -6 route add fc00:c::/64 encap seg6 mode encap segs fc00:b::10 dev veth-rt1-h1
    run ip netns exec R1 ip -6 route add fc00:23::/64 via fc00:12::2

    # configure R2
    run ip netns exec R2 ip link set veth-rt2-rt1 up
    run ip netns exec R2 ip addr add fc00:12::2/64 dev veth-rt2-rt1
    run ip netns exec R2 ip -6 route add fc00:a::/64 via fc00:12::1
}

connect_rt2_rt3 () {
    # create veth peer
    run ip link add veth-rt2-rt3 type veth peer name veth-rt3-rt2
    run ip link set veth-rt2-rt3 netns R2
    run ip link set veth-rt3-rt2 netns R3

    # configure R2
    run ip netns exec R2 ip link set veth-rt2-rt3 up
    run ip netns exec R2 ip addr add fc00:23::1/64 dev veth-rt2-rt3
    run ip netns exec R2 ip -6 route add fc00:c::/64 via fc00:23::2

    # configure R3
    run ip netns exec R3 ip link set veth-rt3-rt2 up
    run ip netns exec R3 ip addr add fc00:23::2/64 dev veth-rt3-rt2
    run ip netns exec R3 ip -6 route add fc00:b::/64 via fc00:23::1
    run ip netns exec R3 ip -6 route add fc00:a::/64 via fc00:23::1
    run ip netns exec R3 ip -6 route add fc00:12::/64 via fc00:23::1
}

# exec functions
create_R1
create_R2
create_R3

connect_rt1_rt2
connect_rt2_rt3

status=0; $SHELL || status=$?
exit $status

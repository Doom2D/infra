{nixpkgs}: {
  natPort = natStart: natPortsCount: num: let
    inNat = natStart + num;
  in
    if inNat >= natStart + natPortsCount || inNat < natStart
    then nixpkgs.lib.throw "Port not in NAT range!"
    else inNat;

  tcpDnat = host: dport: "tcp dport ${builtins.toString dport} dnat ip to ${host}";
}

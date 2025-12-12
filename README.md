gotop-cli
=========

A terminal tool to show price of gold, silver, forex...

### Usage

```bash
# platform sina, symbol: xau|xag|autd|agtd|xaucny|xagcny|usdidx
./gotop -p sina -s xau
# platform east-moeny, symbol: xau|xag|autd|mautd|agtd
./gotop -p east-money -s autd
# platform itick, symbol: xau|xag|xaucny|usd2cnh 已废弃
./gotop -p itick -s usd2cnh
# platform cmb, symbol: cmb-au [招行黄金活期]|usd2cny [招行外汇人民币汇率]
./gotop -p cmb -s cmb-au
./gotop -p cmb -s usd2cny
# platform cmbc, symbol: cmbc-au [民生银行积存金（京东金融代销）]
./gotop -p cmbc
# platform icbc, symbol: icbc-au [工行积存金]
./gotop -p icbc
```

### Screenshots

![](./screenshot-1.png)
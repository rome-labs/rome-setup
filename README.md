# Devnet Rome Stack Setup for Local Testing

This repository provides scripts to set up the full Rome stack on your local machine, including services such as **Geth**, **Rhea**, **Proxy**, **Hercules**, **Deposit UI**, and **Explorer**.

Please make sure `docker`, `dockper compose` is installed on your local machine/ server.

---
## quick setup

1. Clone this repo and `cd rome-setup`
2. Get solana keypair. [solana-keypair-generator.web.app](https://solana-keypair-generator.web.app/) (⚠️ not for production use). Paste the private key in `docker/keys/rhea-sender.json` and `docker/keys/proxy-sender.json` files.
3. Use the public key to airdrop devnet sols from solana faucet: [https://faucet.solana.com/](https://faucet.solana.com/)
4. Register Chain ID using Rome register ui: [https://register.devnet.romeprotocol.xyz/](https://register.devnet.romeprotocol.xyz/).
5. Replace this chain id in `l2_setup.sh`
6. Copy latest solana slot from [https://explorer.solana.com/?cluster=devnet](https://explorer.solana.com/?cluster=devnet)
7. Replace this in `l2_setup.sh` 
8. Update solana RPC URL in `l2_setup.sh`  if needed
9. run following bash command

```bash
sudo chmod +x l2_setup.sh
./l2_setup.sh
```
10. Open http://localhost:3000 deposit UI. First time it might take few minutes and if you see some error just refresh web browser.


***Setup Explorer (Romescout)***

```bash
sudo chmod +x explorer_setup.sh
./explorer_setup.sh
```
Open http://localhost:1000 to see explorer.
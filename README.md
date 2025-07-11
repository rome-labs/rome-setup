# Devnet Rome Stack Setup for Local Testing

This repository provides scripts to set up the full Rome stack on your local machine, including services such as **Geth**, **Rhea**, **Proxy**, **Hercules**, **Deposit UI**, and **Explorer**.

Please make sure `docker` and `docker compose` are installed on your local machine or server.

## Quick Setup

1. Clone this repo and `cd rome-setup`  
2. Get Solana keypair from <a href="https://solana-keypair-generator.web.app/" target="_blank">solana-keypair-generator.web.app</a> (⚠️ not for production use) and create a Solana keypair.  
3. Paste the private key in `docker/keys/rhea-sender.json` and `docker/keys/proxy-sender.json` files.  
4. Use the public key to airdrop devnet SOLs from the Solana faucet: <a href="https://faucet.solana.com/" target="_blank">https://faucet.solana.com/</a>  
5. Register Chain ID using the Rome register UI: <a href="https://register.devnet.romeprotocol.xyz/" target="_blank">https://register.devnet.romeprotocol.xyz/</a>  
6. Replace this chain ID in `l2_setup.sh`  
7. Copy latest Solana slot from <a href="https://explorer.solana.com/?cluster=devnet" target="_blank">https://explorer.solana.com/?cluster=devnet</a>  
8. Replace this in `l2_setup.sh`  
9. Update Solana RPC URL in `l2_setup.sh` if needed  
10. Run the following bash command:

```bash
sudo chmod +x l2_setup.sh
./l2_setup.sh
```
10. Open http://localhost:3000 deposit UI. First time it might take few minutes and if you see some error just refresh web browser.


**Setup Block Explorer (Romescout)**

```bash
sudo chmod +x explorer_setup.sh
./explorer_setup.sh
```
Open http://localhost:1000 to see explorer.

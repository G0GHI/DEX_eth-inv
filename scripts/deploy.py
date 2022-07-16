from brownie import accounts, config, INVtokenCreator, DEX_eth_inv
from scripts.helpfulScripts import get_account


def deploy_DEX_and_tokenCreator():
    account = get_account()
    inv_token = INVtokenCreator.deploy({"from": account})
    dex = DEX_eth_inv.deploy(
        inv_token.address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"DEX contract deployed to {dex.address}")


def main():
    deploy_DEX_and_tokenCreator()

# ETHsub

This is an ethereum subscription payment protocol built with solidity.

## Componenets
1. Subscription.sol - this is the subscription contract to whcih users subscribe and from which the creator (person being subscribed to) recieves/withdraws their ether or tokens.
2. UserAccount.sol - This is the user's smart contract which stores their subscrptions and hte funds for paying these subscriptions. The reason behind having a seperate smart contract is the lack of a allowance function in native ether.

## Steps to Recreate
UserAccount:
1. Deposit funds.
2. Add the subscription contract addresses you wish to subscribe to.
3. Add you UserAccount Address to the subscriptions.sol contracts you would like to subscribe to.

Subscription:
1. Set subscription period.
2. Set subscription value.
3. Trigger startSubscription.
4. Claim the subscriptions - this allows multiple periods to accrue.
5. withdraw the funds - there is ana option to withdraw your ether balance as any token on Kyber Netowrk using an integration.

[VIDEO LINK OF ABOVE STEPS](https://drive.google.com/drive/folders/1EmiZz76eii5Ieaz5EXmG4Q_LWc-5lLmp?usp=sharing) 



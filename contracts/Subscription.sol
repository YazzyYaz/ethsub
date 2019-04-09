pragma solidity ^0.5.0;

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface User {
    function pullToken(ERC20 token, uint amount) external returns (bool);
    function pullEther(uint amount) external  returns (bool);
}

contract Subscription {

    //plan for failed payments if balance is below they are removes from subscribers or another mapping of address and bool calle lapsedSub

    address owner;
    address[] public subscribers;
    mapping (address => bool) public isSubscriber;
    uint baseTime;
    uint subscriptionPeriod;
    uint subscriptionValue;

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    modifier ifValidTime {
        require(now >= baseTime + subscriptionPeriod);
        _;
    }

    constructor(address _owner) public {
        owner = _owner;
    }

     /// @notice Fallback function - recieves ETH but doesn't alter contributor stakes or raised balance.
    function() external payable {
    }

    function setSubscriptionPeriod(uint _days) public onlyOwner {
        //minutes for testing only
        subscriptionPeriod = _days * (60 seconds);
    }

    function startSubscription() public onlyOwner {
        baseTime = now;
    }

    function setSubscriptionValue(uint _value) public onlyOwner {
        subscriptionValue = _value;
    }

    function subscribe(address _sub) public {
        require(!isSubscriber[_sub]); //only new contributor
        require(_sub != owner);
        isSubscriber[_sub] = true;
        subscribers.push(_sub);

        //if now > base take payment now? or pro rata payment for remaining time
    }

    function unsubscribe(address _sub) public {
        require(isSubscriber[_sub]);
        isSubscriber[_sub] = false;
        for (uint i=0; i < subscribers.length - 1; i++)
            if (subscribers[i] == _sub) {
                subscribers[i] = subscribers[subscribers.length - 1];
                break;
            }
        subscribers.length -= 1;

        //pro rata payment for used time?
    }

    function claim() public onlyOwner ifValidTime {
        for (uint i = 0; i < subscribers.length; i++) {
            uint bal = address(subscribers[i]).balance;

            if (bal >= 5) {
                require(User(subscribers[i]).pullEther(5));
            }

            //if balance below remove from subscribers or lapsedSub bool set to true
        }
    }

    ///@dev function to check balance only returns balances in opperating and liquidating periods
    function checkEthBalance() public view returns (uint) {
        return address(this).balance;
    }

}

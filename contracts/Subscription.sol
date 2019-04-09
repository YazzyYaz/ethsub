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

interface UserAccount {
    function pullToken(ERC20 token, uint amount) external returns (bool);
    function pullEther(uint amount) external  returns (bool);
    function getOwner() external returns (address);
}

contract Subscription {

    address payable owner;
    address[] public subscribers;
    mapping (address => bool) public isSubscriber;
    mapping (address => uint) public commitments;
    mapping (address =>uint) public baseTimes;
    uint subscriptionPeriod;
    uint subscriptionValue;
    bool started;

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    constructor(address payable _owner) public {
        owner = _owner;
    }

     /// @notice Fallback function - recieves ETH but doesn't alter contributor stakes or raised balance.
    function() external payable {
    }

    function getSubscriptionPeriodinDays() public view returns(uint) {
        return subscriptionPeriod;
    }

    function getSubscriptionValue() public view returns (uint) {
        return subscriptionValue;
    }

    function getSubscribers() external view returns(address[] memory) {
        return subscribers;
    }

    function getSubscriberCount() external view returns(uint) {
        return subscribers.length;
    }

    function setSubscriptionPeriod(uint _days) public onlyOwner {
        //minutes for testing only
        subscriptionPeriod = _days * (60 seconds);
    }

    function startSubscription() public onlyOwner {
        started = true;
    }

    function setSubscriptionValue(uint _value) public onlyOwner {
        subscriptionValue = _value;
    }

    function subscribe(address _sub) public {
        require(!isSubscriber[_sub]); //only new subscriber
        require(_sub != owner);
        require(started == true);
        address accOwner =  UserAccount(_sub).getOwner();

        if (msg.sender == accOwner) {
            baseTimes[_sub] = now;
            require(UserAccount(_sub).pullEther(subscriptionValue));
            isSubscriber[_sub] = true;
            subscribers.push(_sub);
        } else {
            revert();
        }

    }

    function unsubscribe(address _sub) public {
        require(isSubscriber[_sub]);
        address accOwner =  UserAccount(_sub).getOwner();
        if (msg.sender == owner) {
            isSubscriber[_sub] = false;
            for (uint i=0; i < subscribers.length - 1; i++)
            if (subscribers[i] == _sub) {
                subscribers[i] = subscribers[subscribers.length - 1];
                break;
            }
        subscribers.length -= 1;
        } else if (msg.sender == accOwner) {
            isSubscriber[_sub] = false;
            for (uint i=0; i < subscribers.length - 1; i++)
            if (subscribers[i] == _sub) {
                subscribers[i] = subscribers[subscribers.length - 1];
                break;
            }
        subscribers.length -= 1;
        } else {
            revert();
        }
    }

    function claim() public onlyOwner  {

        for (uint i = 0; i < subscribers.length; i++) {
            uint timeLapsed = (now - baseTimes[subscribers[i]])/subscriptionPeriod;
            uint paymentAmt = timeLapsed * subscriptionValue;

            uint bal = address(subscribers[i]).balance;

            if (timeLapsed > 0){
                if (bal >= paymentAmt) {
                require(UserAccount(subscribers[i]).pullEther(paymentAmt));
                baseTimes[subscribers[i]] = now;
                 } else {
                isSubscriber[subscribers[i]] = false;
                subscribers[i] = subscribers[subscribers.length - 1];
                subscribers.length--;
                delete baseTimes[subscribers[i]];
                break;
                }
            } else {
                return;
            }
        }
    }

    ///@dev function to check balance only returns balances in opperating and liquidating periods
    function checkEthBalance() public view returns (uint) {
        return address(this).balance;
    }

    /*
    function withdrawToken(ERC20 token, uint amount) public onlyOwner returns (bool){
        require(token.transfer(owner, amount));
        return true;
    }
    */

    function withdrawEther(uint amount) public onlyOwner returns (bool){
        owner.transfer(amount);
        return true;
    }

}

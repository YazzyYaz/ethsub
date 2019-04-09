pragma solidity 0.5.0;


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

contract UserAccount {

    address payable ownerPay;
    address owner;
    mapping(address=>bool) internal subscriptions;
    address[] internal subscriptionsGroup;

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    modifier onlySubscriptions {
      require(subscriptions[msg.sender]);
      _;
    }

    constructor(address payable _owner) public {
        owner = _owner;
        ownerPay = _owner;
    }

    function addSubscription(address _subscription) public onlyOwner {
        require(!subscriptions[_subscription]); // prevent duplicates.
        subscriptions[_subscription] = true;
        subscriptionsGroup.push(_subscription);
    }

    function removeSubscription(address _subscription) public onlyOwner {
        require(subscriptions[_subscription]);
        subscriptions[_subscription] = false;

        for (uint i = 0; i < subscriptionsGroup.length; ++i) {
            if (subscriptionsGroup[i] == _subscription) {
                subscriptionsGroup[i] = subscriptionsGroup[subscriptionsGroup.length - 1];
                subscriptionsGroup.length--;
                break;
            }
        }
    }

    function getSubscriptions() external view returns(address[] memory) {
        return subscriptionsGroup;
    }


     /// @notice Fallback function - recieves ETH but doesn't alter contributor stakes or raised balance.
    function() external onlyOwner payable {

    }

    ///@dev function to check balance only returns balances in opperating and liquidating periods
    function checkEthBalance() public view returns (uint) {
        return address(this).balance;
    }

    function checkTokBalance(ERC20 token) public view returns (uint) {
        return token.balanceOf(address(this));
    }

    /// @dev send erc20token to the reserve address
    /// @param token ERC20 The address of the token contract
    function pullToken(ERC20 token, uint amount) external onlySubscriptions returns (bool){
        require(token.transfer(msg.sender, amount));
        return true;
    }

    ///@dev Send ether to the reserve address
    function pullEther(uint amount) external onlySubscriptions returns (bool){
        address(msg.sender).transfer(amount);
        return true;
    }

    function getOwner() external onlySubscriptions returns (address){
        return owner;
    }

    /*
    function withdrawToken(ERC20 token, uint amount) public onlyOwner returns (bool){
        require(token.transfer(owner, amount));
        return true;
    }
    */

    function withdrawEther(uint amount) public onlyOwner returns (bool){
        ownerPay.transfer(amount);
        return true;
    }

}

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

contract UserAccount {

    address payable owner;
    address payable payee;

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    modifier onlyPayee {
      require(msg.sender == payee);
      _;
    }

    constructor(address payable _owner) public {
        owner = _owner;
    }

    function setPayee(address payable _payee) public onlyOwner {
        payee = _payee;
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
    function pullToken(ERC20 token, uint amount) external onlyPayee returns (bool){
        require(token.transfer(payee, amount));
        return true;
    }

    ///@dev Send ether to the reserve address
    function pullEther(uint amount) external onlyPayee returns (bool){
        address(payee).transfer(amount);
        return true;
    }
    function withdrawToken(ERC20 token, uint amount) public onlyOwner returns (bool){
        require(token.transfer(owner, amount));
        return true;
    }
    function withdrawEther(uint amount) public onlyOwner returns (bool){
        owner.transfer(amount);
        return true;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SafeMath { // Only relevant functions
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256)   {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Maida {

    using SafeMath for uint;

    string private      tokenName;
    string private      tokenSymbol;
    uint8 private       tokenDecimals;
    uint256 private     tokenSupply;

    address private     tokenFounder; 
    address[] private   minters;
 
    mapping (address => uint256) private                        balances;
    mapping (address => mapping (address => uint256)) private   allowed;

    constructor() {

        tokenName = "Maida";
        tokenSymbol = "MDA";
        tokenFounder = msg.sender;
        tokenDecimals = 18;
        balances[msg.sender] = 21000000;
        emit Transfer(address(0), msg.sender, tokenSupply);

    }

    function totalSupply() public view returns (uint256) {
        return tokenSupply;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }
    
    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value, "The account from which you are sending currency dosen't have enough funds to cover the transaction.");

        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        /*
        NOTE:
        Before this function is excecuted, the allowance function as well as the approval function must be executed.
        The allowance function will create an allowance that is equal to the value so that the transfer will go through,
        then the approval function will create an event and approve the function.
        */

        require(_value <= balances[_from], "The account from which you are sending currency dosen't have enough funds to cover the transaction.");

        require(_value <= allowed[_from][msg.sender], "The value you are trying to send exceeds senders allowance.");

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);

        allowed[_from][msg.sender].sub(_value); //Now that the transaction has gone through, the allowance is reset.

        emit Transfer(_from, _to, _value);

        return true;

    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value; 

        /*
        NOTE:
        The allowances array functions as a record of transactions.
        _spender will now be allowed to spend _value tokens because they have been sent that many tokens.
        This function is executed BEFORE the transfer function. This itself dosent approve the function, but
        creates the necessary conditions for approval (the allowance is created), so that when the allowance is
        checked in the transfer function, it will go through.
        */

        emit Approval(msg.sender, _spender, _value);
        return true;

    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _receiver, uint256 _value);

    /*
    NOTE:
    Any function past this point is beyond the recommended ERC20 standard.
    */
    
    function addMinter(address toAdd) public returns (bool) {

        /*
        NOTE:
        A minter is someone who is able to create new coins.
        */

        if (msg.sender == tokenFounder) {
            minters.push(toAdd);
            return true;
        }
        return false;
    }

    function removeMinter(address toRemove) public returns (bool) {
        address[] memory newMinters;
        uint j = 0;
        for (uint i = 0; i < minters.length; i++) {
            if (minters[i] != toRemove) {
                newMinters[j];
                j += 1;

            }
        }
        minters = newMinters;
        return true;
    }

    function mint(address destination, uint256 value) public returns (bool) {
        bool check = false;

        for (uint i = 0; i < minters.length; i++) {
            if (minters[i] == msg.sender) {
                check = true;
            }
        }

        if (check) {
            balances[destination] += value;
            return true;
        }

        emit Transfer(address(0), destination, value);

        return false;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Maida {

    string public       tokenName;
    string public       tokenSymbol;
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
        balances[0x51c3956F11A50F11288c186643eE1268716Cd89F] = 21000000;
        emit Transfer(address(0), 0x5A86f0cafD4ef3ba4f0344C138afcC84bd1ED222, tokenSupply);

    }

    function totalSupply() external view returns (uint256) {
        return tokenSupply - balances[address(0)];
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {

        require(balances[msg.sender] >= _value, 
                "The account from which you are sending currency dosen't have enough funds to cover the transaction.");

        require(_value > 0,
                "Transaction amounts must be greater than zero.");

        balances[_to] += _value;
        balances[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);

        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {

        /*
        NOTE:
        Before this function is excecuted, the allowance function as well as the approval function must be executed.
        The allowance function will create an allowance that is equal to the value so that the transfer will go through,
        then the approval function will create an event and approve the function.
        */

        require(balances[_from] >= _value, 
                "The account from which you are sending currency dosen't have enough funds to cover the transaction.");

        require(_value <= allowed[_from][msg.sender],
                "The value you are trying to send exceeds senders allowance.");

        require(_value >= 0, 
                "You cannot create a transaction for negative amounts.");

        balances[_to] += _value;
        balances[_from] -= _value;

        if (allowed[_from][msg.sender] < (2 ** 256 - 1)) {
            allowed[_from][msg.sender] -= _value; //Now that the transaction has gone through, the allowance is reset.
        }

        emit Transfer(_from, _to, _value);

        return true;

    }

    function approve(address _spender, uint256 _value) external returns (bool success) {

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

    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _receiver, uint256 _value);

    /*
    NOTE:
    Any function past this point is beyond the recommended ERC20 standard.
    */

    function addMinter(address toAdd) external returns (bool) {
        if (msg.sender == tokenFounder) {
            minters.push(toAdd);
            return true;
        }
        return false;
    }

    function removeMinter(address toRemove) external returns (bool) {
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

    function mint(address destination, uint256 value) external returns (bool) {
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

        return false;
    }

}
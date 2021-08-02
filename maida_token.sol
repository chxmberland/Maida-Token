// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Maida {

    string      public tokenName = "Maida";
    string      public tokenSymbol = "MDA";
    address     private tokenFounder;   //Address of the founder

    uint8       private tokenDecimals = 18;                       //The number of decimals that are displayed for fractional transactions
    uint256     private tokenSupply;                            //The total number of tokens in circulation
    uint256     private constant MAX_DENOMINATION = 2**256 - 1; //Maximum denomination allowed in an account
 
    mapping     (address => uint256) private _balances;                         //Mapping accounts to balances
    mapping     (address => mapping (address => uint256)) private _allowed;  //Mapping accounts to their allowed spend to other accounts

    //This is the constructor, which will be initialized once by the creator of the coin
    constructor(uint256 _initialAmount, uint8 _decimals) {

        tokenFounder = msg.sender;

        tokenDecimals = _decimals;
        tokenSupply = _initialAmount; //Setting the total token supply equal to the initial amount
        _balances[msg.sender] = _initialAmount; //Sending the intial amount of currency to the creator


    }

    function decimals() external view returns (uint8) {
        return tokenDecimals;
    }

    function totalSupply() external view returns (uint256) {
        return tokenSupply;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {

        require(_balances[msg.sender] >= _value, 
                "The account from which you are sending currency dosen't have enough funds to cover the transaction.");

        require(_value > 0,
                "Transaction amounts must be greater than zero.");

        _balances[_to] += _value;
        _balances[msg.sender] -= _value;

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

        require(_balances[_from] >= _value, 
                "The account from which you are sending currency dosen't have enough funds to cover the transaction.");

        require(_value <= _allowed[_from][msg.sender],
                "The value you are trying to send exceeds senders allowance.");

        require(_value >= 0, 
                "You cannot create a transaction for negative amounts.");

        _balances[_to] += _value;
        _balances[_from] -= _value;

        if (_allowed[_from][msg.sender] < (2 ** 256 - 1)) {
            _allowed[_from][msg.sender] -= _value; //Now that the transaction has gone through, the allowance is reset.
        }

        emit Transfer(_from, _to, _value);

        return true;

    }

    function approve(address _spender, uint256 _value) external returns (bool success) {

        _allowed[msg.sender][_spender] = _value; 
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
        return _allowed[_owner][_spender];
    }


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _receiver, uint256 _value);

}
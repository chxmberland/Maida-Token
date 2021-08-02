// https://eips.ethereum.org/EIPS/eip-20
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface Token {
    
    //The following methods are optional

    /// @return name The name of the token
    function name() public view returns (string name);

    /// @return symbol The three letter symbol of the token
    function symbol() public view returns (string symbol);

    /// @return decimals The maximum number of decimals  that can be used in a fractional transaction
    function decimals() public view returns (uint8 decimals);

    /// @return totalSupply The total number of tokens circulating
    function totalSupply() public view returns (uint256 totalSupply);

    //The following methods AND events are required

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)  external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender  , uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Standard_Token is Token { //This is an example implementation of the Token interface
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string  memory _tokenSymbol) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value, "token balance is lower than the value requested");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value, "token balance or allowance is lower than amount requested");
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract Maida is Token {

    string public tokenName = "Maida";
    string public tokenSymbol = "MDA";
    address private tokenFounder;   //Address of the founder

    uint8 private tokenDecimals = 18;                       //The number of decimals that are displayed for fractional transactions
    uint256 private tokenSupply;                            //The total number of tokens in circulation
    uint256 private constant MAX_DENOMINATION = 2**256 - 1; //Maximum denomination allowed in an account
 
    mapping (address => uint256) private _balances;                         //Mapping accounts to balances
    mapping (address => mapping (address => uint256)) private _allowed;  //Mapping accounts to their allowed spend to other accounts

    //This is the constructor, which will be initialized once by the creator of the coin
    constructor(uint256 _initialAmount, uint8 _decimals) {

        tokenFounder = msg.sender;

        tokenDecimals = _decimals;
        tokenSupply = _initialAmount; //Setting the total token supply equal to the initial amount
        _balances[msg.sender] = _initialAmount; //Sending the intial amount of currency to the creator


    }

    /// @return tokenDecimals The number of decimals used in fractional transactions
    function decimals() external view returns (uint8) {
        return tokenDecimals;
    }

    /// @return totalSupply The total amount of Maida in circulations
    function totalSupply() external view returns (uint256) {
        return totalSupply;
    }

    /// @param _owner The address whose balance is checked
    /// @return balance The balance of _owner
    function balanceOf(address _owner) external view returns (uint256 balance) {
        return _balances[msg.sender];
    }

    /// @notice Transfer '_value' from 'msg.sender' to '_to', and emits a transfer event
    /// @param _to The ethereum adress where the money is sent
    /// @param _value The number of tokens being sent
    /// @return sucsess Boolean which indicates that the transaction has gone through
    function transfer(address _to, uint256 _value) external returns (bool success) {

        require(_balances(msg.sender) >= _value, 
                "The account from which you are sending currency dosen't have enough funds to cover the transaction.");

        require(_value > 0,
                "Transaction amounts must be greater than zero.");

        _balances[_to] += _value;
        _balances[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);

        return true;

    }

    /// @notice Sends '_value' to '_to' from '_from' on the condition the transaction is approved by '_from'. Someone else spending on your behalf.
    /// @param _from The address that is sending the tokens
    /// @param _to The address that is recieving the tokens
    /// @param _value The number of tokens being sent from '_from' to '_to'
    /// @return success A boolean which indicates wether or not the transaction was successful
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

        if (_allowed[_from][msg.sender] < uint(-1)) {
            _allowed[_from][msg.sender] -= _value; //Now that the transaction has gone through, the allowance is reset.
        }

        emit Transfer(_from, _to, _value);

        return true;

    }

    /// @notice Approves a transaction based on the condition that 'msg.sender' is allowed to send '_value' to '_reciever'
    /// @param _spender The address that tokens are being sent to
    /// @param _value The number of tokens being sent to '_reciever'
    /// @return success A boolean which indicates wether the transaction should be approved
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

    /// @param _owner The address sending tokens
    /// @param _spender The address recieving tokens
    /// @return remaining An unsigned intiger represneing the remaining allowance '_owner' can send to '_reciever'
    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
        return _allowed[_owner][_spender];
    }


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _receiver, uint256 _value);

}
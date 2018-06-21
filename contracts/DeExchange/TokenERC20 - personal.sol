pragma solidity ^0.4.18;

contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;
   //定义合约管理员
    address public Manager;
    //Only manager can modify. 
   //定义修饰函数：仅合约管理员能修改
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
     struct asset {
          address owner; //the owner's account. 所有者帐号
          string name; 
          string AttachInfo; //additional information 备注或附加信息。
        }
    // This creates an array with all balances
    mapping (uint256=>asset) public balanceOf;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function TokenERC20(
        string tokenName,
        string tokenSymbol
    ) public {
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        manager=msg.sender;    
}

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_value].owner >= _from);
        // Check for overflows
        // Modify the ower of the asset
        balanceOf[_value].owner = _to;
        Transfer(_from, _to, _value);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
   /**
     * Create  tokens
     *
     * Create  one ` tokens to `_to` from manager
     *
     * @param _to The address of the owner
     * @param _name the name of the asset to create
     * @param _attachInfo the additional information  of the asset to create
     */
    function create(address _to, string _name, string  _attach) public onlyManager {
        append(balanceOf, asset(_to,_name, _attach);
    }
    /**
     * Save  tokens
     *
     * Save `_value` tokens to `_to` DeExchange contract from your account
     *
     * @param _to The address of the DeExChange contract
     * @param _value the amount to save
     */

   function save(address _to, uint256 _value) public {
        _transfer(tx.origin, _to, _value);
    }
        /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public onlyManager returns (bool success) {
        delete balanceOf[_value];
        Burn(msg.sender, _value);
        return true;
    }
 }

pragma solidity ^0.4.18;
//���ô�������
contract Token {
    bytes32 public standard;          //�������standard
    bytes32 public name;              //�������name
    bytes32 public symbol;           //�������symbol;
    uint256 public totalSupply;    //�������totalSupply
    uint8 public decimals;           //�������decimals
    bool public allowTransactions;    //�������allowTransactionsΪ�߼�����
    mapping (address => uint256) public balanceOf;     //�����ʻ�����
    mapping (address => mapping (address => uint256)) public allowance;     //�����ʻ���Ȩ�ʻ���֧������
    function transfer(address _to, uint _value) public returns (bool success);    //����ת�ʺ��������ز���ֵ
    function approveAndCall(address _spender, uint _value, bytes _extraData) public returns (bool success);   //��ָ���ʻ����ſɲ������
    function approve(address _spender, uint _value) public returns (bool success);   //��ָ���˻���Ȩ�ɲ������
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);    //����Ȩ�ʻ�ת�ʺ������ӷ�����ת��������
}
//����ȥ���Ļ����׺�Լ
contract Exchange {
//��ȫ�ˣ���ҪҪôc/a����b��Ҫôa����0
  function safeMul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
//��ȫ������Ҫ����С�ڻ���ڱ�����
  function safeSub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }

//��ȫ�ӣ���Ҫ�ʹ��ڼ����뱻����
  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c>=a && c>=b);
    return c;
  }
  address public owner;    //�����Լӵ����Ϊ��ַ����
  mapping (address => uint256) public invalidOrder;   //������Ч������mapping����
  event SetOwner(address indexed previousOwner, address indexed newOwner);   //�������ú�Լӵ�����¼�
//��������ɺ�Լ�����޸����κ��� 
 modifier onlyOwner {
    require(msg.sender == owner);
     _;
  }
//��Լ�����ʻ�����
  function setOwner(address newOwner) public onlyOwner {
    SetOwner(owner, newOwner);
    owner = newOwner;
  }
//��ѯ��ǰ��Լ���˵�ַ
  function getOwner() public constant returns (address out) {
    return owner;
  }
//������Ч����
  function invalidateOrdersBefore(address user, uint256 nonce) public onlyAdmin {
    if (nonce < invalidOrder[user]) revert();    //��������������С���û��ѵǼ�����������˳���
    invalidOrder[user] = nonce;    //����ָ���û��ʻ�����Ч����Ϊָ�������
  }
//����ָ�����ֵ�ָ���ʻ����������tokens[����][�ʺ�]=���
  mapping (address => mapping (address => uint256)) public tokens; //mapping of token addresses to mapping of account balances
//��������˻����� amins[�ʻ�]=true/false
  mapping (address => bool) public admins;
//����ָ���ʻ����»�Ծ���� lastActiveTransaction[�ʻ�]=���»�Ծ����
  mapping (address => uint256) public lastActiveTransaction;
//��������д�����Ķ��  orderFills[������]=���
  mapping (bytes32 => uint256) public orderFills;
 //������ȡ�����ѵ��˻���ַ 
 address public feeAccount;
//���嶳��ʱ�䣬�ڸ�ʱ���ڲ��ܳ�����������������
  uint256 public inactivityReleasePeriod;
//��������ɽ����嵥trades[���]=true/fase
  mapping (bytes32 => bool) public traded;
//�����Ƿ����ⲿ����foreignToken[��ַ]=true/fase
  mapping (address => bool) public foreignToken;
//�����ѳ��������嵥withdrawn[���]=true/false
  mapping (bytes32 => bool) public withdrawn;
//����ҵ��¼���������֣��������������֣��������ҵ���Ч�ڣ���������ҵ��˻���ǩ��v,r,s)
  event Order(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
//���峷���¼���������֣��������������֣��������ҵ���Ч�ڣ���������ҵ��˻���ǩ��v,r,s)
  event Cancel(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
//���彻���¼���������֣��������������֣�����������˻��������˻�)  
event Trade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, address get, address give);
//�������¼���������֣��˻�������������� 
 event Deposit(address token, address user, uint256 amount, uint256 balance);
//��������������¼���������֣��˻�������������� 
  event ForeignTokenWithdraw(address token, address user, uint256 amount, uint256 balance);
//��������¼���������֣��˻�������������� 
  event Withdraw(address token, address user, uint256 amount, uint256 balance);

//���嶳��ʱ��
  function setInactivityReleasePeriod(uint256 expiry) public onlyAdmin returns (bool success) {
    if (expiry > 1000000) revert();    //������ʱ�䳬��10���죬��������Ч
    inactivityReleasePeriod = expiry;   //�趨����ʱ��
    return true;
  }
//���캯��
  function Exchange(address feeAccount_) public {
    owner = msg.sender;    //��Լ����Ϊ��Լ������
    feeAccount = feeAccount_;    //������ȡ�����Ѻ�Լ
    inactivityReleasePeriod = 100000;    // ���ö���ʱ�䳬��1��87600��
  }
//���ù����ʻ�
  function setAdmin(address admin, bool isAdmin) public onlyOwner {
    admins[admin] = isAdmin;
  }
//��������ɹ����ʻ��������κ���
  modifier onlyAdmin {
    if (msg.sender != owner && !admins[msg.sender]) revert();   //��������߲��Ǻ�Լ���˻�����ʻ������˳�
    _;
  }
//�������ⲿ����
  function() external {
    revert();
  }
//��Һ��������֣�������
  function depositToken(address token, uint256 amount) public{
    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);    //��tokens�����н������� tokens[����][�ʻ�]=ԭ�ж��+��������
    lastActiveTransaction[msg.sender] = block.number;   //�����»�Ծ���������д�ŵ�ǰ�����lastActiveTransaction[�ʻ�]=��ǰ�����
    if (!Token(token).transferFrom(msg.sender, this, amount)) revert();  //ִ��ת�Ҳ�����������Ҵ���Ϣ�������˻�ת��ָ���������ҵ����׺�Լ�ʻ���
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);  //����¼�
  }
//�����ⲿ�����ֺ���
 function depositForeignToken(address token, uint256 amount,address user) public onlyAdmin{
    tokens[token][user] = safeAdd(tokens[token][user], amount);    //��tokens�����н������� tokens[����][�ʻ�]=ԭ�ж��+��������
    lastActiveTransaction[user] = block.number;   //�����»�Ծ���������д�ŵ�ǰ�����lastActiveTransaction[�ʻ�]=��ǰ�����
    //���øñ���Ϊ�������֣����û��������������Լ�д�����Ӧ������������
    ForeignToken[token]=true;
    Deposit(token, msg.sender, amount, tokens[token][user]);  //����¼�
  }
//��������Һ���
  function deposit() public payable {
    tokens[address(0)][msg.sender] = safeAdd(tokens[address(0)][msg.sender], msg.value);    //token[0��ַ][�˻�]=ԭ�����+�·��ͽ��
    lastActiveTransaction[msg.sender] = block.number;    //lastActiveTransaction[����ʻ�]=��ǰ�����
    Deposit(address(0), msg.sender, msg.value, tokens[address(0)][msg.sender]);  //����¼�
  }
//��Һ�������ұ��֣�������
  function withdraw(address token, uint256 amount) public returns (bool success) {
    if (safeSub(block.number, lastActiveTransaction[msg.sender]) < inactivityReleasePeriod) revert();  //��������ǰ����ʱ���ȥ���´��ʱ�䲻��С�ڶ���ʱ��
    if (tokens[token][msg.sender] < amount) revert();   //�������û�������ʻ�����С���������
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);  //��tokens�����н��û�������ʻ�����ȥ�������
    if (token == address(0)) {      //����ұ���Ϊ������ʱ���ӱ���Լ��ֱ��������ʻ�ת��ָ������������
      if (!msg.sender.send(amount)) revert();
    } else if (foreignToken[token]==true){   //����������ң�����¼���ʾ��ͬʱ��������Լ��ִ����Ҳ���
     ForeignTokenWithtraw(token,msg.sender, amount, tokens[token][msg.sender]);
  }else
{   //��Ϊ�������ұ���ʱ���Ӵ���ұ��ֱ���Լ�ʻ�ת������û��ʻ�ָ��������ұ��֡�
      if (!Token(token).transfer(msg.sender, amount)) revert();
    }
   //����¼�
    Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
    return true;
  }
//�����ʻ���Һ���������ұ��֣��������û��ʻ����������ǩ��V��r,s, �����ѣ����ú����������ʱ�䴦�ڶ�����ʱ�����û�ͨ������Ա�ʻ�������
  function adminWithdraw(address token, uint256 amount, address user, uint256 nonce, uint8 v, bytes32 r, bytes32 s, uint256 feeWithdrawal) public onlyAdmin returns (bool success) {
    bytes32 hash = keccak256(this, token, amount, user, nonce);   //ʹ�á���Լ��ַ������ң��������û���ַ������������������ɹ�ϣ�룻
    if (withdrawn[hash]) revert();    //����ù�ϣ�����������withdrawn���ѵǼǣ����˳�
    withdrawn[hash] = true;     //���������withdrawn�еǼǸ���ҹ�ϣ��
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) != user) revert();   //�Թ�ϣ����н���ʶ���Ƿ�Ϊָ���û�ǩ���������ǣ����˳�
    if (feeWithdrawal > 50 finney) feeWithdrawal = 50 finney;     //��������Ѵ���50finney��������Ϊ50finney
    if (tokens[token][user] < amount) revert();   //����û���������С�ڴ������������˳�
    tokens[token][user] = safeSub(tokens[token][user], amount);   //������tokens�жԴ���Ҵ����˻�����ȥָ������
    tokens[token][feeAccount] = safeAdd(tokens[token][feeAccount], safeMul(feeWithdrawal, amount) / 1 ether);   //��tokens�����ж���������ȡ�ʻ��ϼ��������ѣ����+����*����/10**18)
    amount = safeMul((1 ether - feeWithdrawal), amount) / 1 ether;  //�������=��10**18-���ʣ�*����/10**18
    if (token == address(0)) {       //����ǻ����ң���ֱ��������û�ת��ָ������
      if (!user.send(amount)) revert();
    }else if (foreignToken[token]==true){   //����������ң�����¼���ʾ��ͬʱ��������Լ��ִ����Ҳ���
      ForeignTokenWithtraw(token,msg.sender, amount, tokens[token][msg.sender]);
    } else {       //������������ң�����ָ�����ҴӺ�Լ�ʻ���ָ���û�ת��ָ������
      if (!Token(token).transfer(user, amount)) revert();
    }
//���õ�ǰ�û������»�Ծ������Ϊ��ǰ������
    lastActiveTransaction[user] = block.number;
//����¼�
    Withdraw(token, user, amount, tokens[token][user]);
    return true;
  }
//����ָ���û�ָ�������ں�Լ�еĴ����
  function balanceOf(address token, address user) public constant returns (uint256) {
    return tokens[token][user];
  }
//���׺����������ɽ��׹���Ա������������ֵ���飬��ַ���飬maker��taker��ǩ��V,rs���飩
  function trade(uint256[8] tradeValues, address[4] tradeAddresses, uint8[2] v, bytes32[4] rs) public onlyAdmin returns (bool success) {
    /* amount is in amountBuy terms */
    /* tradeValues     ����ֵ���鶨��
       [0] amountBuy        // ��������
       [1] amountSell         //��������
       [2] expires              //ʱЧ
       [3] nonce             //�����
       [4] amount           //�ṩ�Ķ�����������amountBuy����ͬ��
       [5] tradeNonce     //���������
       [6] feeMake         //�ṩ���׷�
       [7] feeTake          //��ȡ���׷�
     tradeAddressses     //���׵�ַ
       [0] tokenBuy       //�������
       [1] tokenSell        //��������
       [2] maker           //����
       [3] taker             //���
     */
     //��������������Ч�����е���������ڽ���ֵ�������ṩ������������˳�
    if (invalidOrder[tradeAddresses[2]] > tradeValues[3]) revert();
   //����������ϣ��=������Լ��ַ�����۱��֣������������������֣�����������ʱЧ������������ң�
    bytes32 orderHash = keccak256(this, tradeAddresses[0], tradeValues[0], tradeAddresses[1], tradeValues[1], tradeValues[2], tradeValues[3], tradeAddresses[2]);
  //ʹ�øù�ϣ�뼰ǩ�������е�����ǩ�����ݣ����н�ǩ������ǩ����ַ��Ϊ�����ʻ���ַ�����˳�   
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", orderHash), v[0], rs[0], rs[1]) != tradeAddresses[2]) revert();
    //���ɽ��׹�ϣ��=��������ϣ��������������ҵ�ַ�������������
    bytes32 tradeHash = keccak256(orderHash, tradeValues[4], tradeAddresses[3], tradeValues[5]); 
   //ʹ�øý��׹�ϣ������ǩ�������н�ǩ��������ַ��Ϊ����ʻ���ַ�����˳���
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", tradeHash), v[1], rs[2], rs[3]) != tradeAddresses[3]) revert();
   //����ý��׹�ϣ�Ѿ�ִ�У����˳�
    if (traded[tradeHash]) revert();
   //�ڽ��׹�ϣ���������ñ����׹�ϣ��ֵΪtrue
    traded[tradeHash] = true;
   //��������õĽ��׷��ʴ���100finney�����׷�������Ϊ100finney
    if (tradeValues[6] > 100 finney) tradeValues[6] = 100 finney;
  //��������õ����ҷ��ʴ���100finney��������Ϊ100finney
    if (tradeValues[7] > 100 finney) tradeValues[7] = 100 finney;
   //���������������+��������>�����ܶ���˳����������������˳���
    if (safeAdd(orderFills[orderHash], tradeValues[4]) > tradeValues[0]) revert();
  //�����ҳ��б�����С�ڶ����ṩ���������˳������ò��������˳���
    if (tokens[tradeAddresses[0]][tradeAddresses[3]] < tradeValues[4]) revert();
  //������Ҵ��۱�����С�ڣ���������/��������)*�����������������˳� ��������������˳���
    if (tokens[tradeAddresses[1]][tradeAddresses[2]] < (safeMul(tradeValues[1], tradeValues[4]) / tradeValues[0])) revert();
  //tokens[��������][���]=tokens[��������][���]-��������
    tokens[tradeAddresses[0]][tradeAddresses[3]] = safeSub(tokens[tradeAddresses[0]][tradeAddresses[3]], tradeValues[4]);
 //tokens[��������][����]=tokens[��������][����]+����������*��10**18-��ҷ��ʣ�/10**18)
    tokens[tradeAddresses[0]][tradeAddresses[2]] = safeAdd(tokens[tradeAddresses[0]][tradeAddresses[2]], safeMul(tradeValues[4], ((1 ether) - tradeValues[6])) / (1 ether));
 //tokens[��������][�������ʻ�]=tokens[��������][�������ʻ�]+(��������*��ҷ��ʣ�/10**18)  
   tokens[tradeAddresses[0]][feeAccount] = safeAdd(tokens[tradeAddresses[0]][feeAccount], safeMul(tradeValues[4], tradeValues[6]) / (1 ether));
 //tokens[��������][����]=tokens[��������][����]-(��������/��������)*��������
    tokens[tradeAddresses[1]][tradeAddresses[2]] = safeSub(tokens[tradeAddresses[1]][tradeAddresses[2]], safeMul(tradeValues[1], tradeValues[4]) / tradeValues[0]);
 //tokens[��������][���]=tokens[��������][���]+(10**18-���ҷ��ʣ�*����������/����������*��������/10**18
    tokens[tradeAddresses[1]][tradeAddresses[3]] = safeAdd(tokens[tradeAddresses[1]][tradeAddresses[3]], safeMul(safeMul(((1 ether) - tradeValues[7]), tradeValues[1]), tradeValues[4]) / tradeValues[0] / (1 ether));
  //tokens[��������][�������ʻ�]=tokens[��������][�������ʻ�]+���ҷ���*����������/����������*��������/10**18
    tokens[tradeAddresses[1]][feeAccount] = safeAdd(tokens[tradeAddresses[1]][feeAccount], safeMul(safeMul(tradeValues[7], tradeValues[1]), tradeValues[4]) / tradeValues[0] / (1 ether));
  // �����������жԸ����������������ϱ��ζ�������
    orderFills[orderHash] = safeAdd(orderFills[orderHash], tradeValues[4]);
  //�������һ�Ծ��Ϊ��ǰ������
    lastActiveTransaction[tradeAddresses[2]] = block.number;
  //������һ�Ծ��Ϊ��ǰ������
    lastActiveTransaction[tradeAddresses[3]] = block.number;
    return true;
  }
}
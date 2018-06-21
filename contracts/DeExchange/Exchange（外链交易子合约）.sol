pragma solidity ^0.4.18;
//���ô�������
contract Token {
    function transfer(address _to, uint _value) public returns (bool success);    //����ת�ʺ��������ز���ֵ
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);    //����Ȩ�ʻ�ת�ʺ������ӷ�����ת��������
}
//����ȥ���Ļ����׺�Լ
contract Exchange {
  address public owner;    //�����Լӵ����Ϊ��ַ����
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
//��������˻����� amins[�ʻ�]=true/false
  mapping (address => bool) public admins;
//�������¼���������֣��˻�������������� 
 event Deposit(address token, address user, uint256 amount, uint256 balance);
//��������¼���������֣��˻�������������� 
  event Withdraw(address token, address user, uint256 amount, uint256 balance);
//���캯��
  function Exchange(address feeAccount_) public {
    owner = msg.sender;    //��Լ����Ϊ��Լ������
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
    if (!Token(token).transferFrom(msg.sender, this, amount)) revert();  //ִ��ת�Ҳ�����������Ҵ���Ϣ�������˻�ת��ָ���������ҵ����׺�Լ�ʻ���
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);  //����¼�
  }
//��������Һ���
  function deposit() public payable {
     Deposit(address(0), msg.sender, msg.value, tokens[address(0)][msg.sender]);  //����¼�
  }
//��Һ�������ұ��֣�������
  function withdraw(address token, uint256 amount,user) public onlyAdmin returns (bool success) {
     if (token == address(0)) {      //����ұ���Ϊ������ʱ���ӱ���Լ��ֱ��������ʻ�ת��ָ������������
      if (!user.send(amount)) revert();
    } else
    {   //��Ϊ�������ұ���ʱ���Ӵ���ұ��ֱ���Լ�ʻ�ת������û��ʻ�ָ��������ұ��֡�
      if (!Token(token).transfer(user, amount)) revert();
     }
   //����¼�
    Withdraw(token, user, amount, tokens[token][user]);
    return true;
   }
}
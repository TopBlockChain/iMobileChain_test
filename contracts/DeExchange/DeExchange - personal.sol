/*ԭ��1������ѡ�������ʲ��Ĵ��ң��ڽ������ܺ�Լ�ǼǴ����������۸񣬹ҵ������ܺ�Լ����save���뺯�����ʲ�ת�����ܺ�Լ�ʻ��ϣ�2����Ҳ�ѯ��������ֱ�Ӷ�������������������ȷ���ļ۸񣬶��������������ܺ�Լ���ͽ��ף����ܺ�Լ�յ��󣬽���Ӧ�����ʲ�ת������ʻ������ʽ��͵������ʻ������������������������ݽ��м����ɾ����3��������Ҫ����������ֱ�ӽ����׺ż��������������ܺ�Լ�����ܺ�Լ��֤��ֱ�ӽ������ʲ�����Ȩת�������ʻ����������������������������*/
pragma solidity ^0.4.18;

interface TokenERC20{
      function transfer(address _to,uint256 _value) public;
      function save(address _to,uint256 _value) public;
} 

contract DeExChange{
    //ExChange things' Information. �����������Ʒ���ݽṹ
    struct ExThingInfo {
          address owner; //the owner's account. �������ʺ�
          TokenERC20 Token;  //the wishing to exchange thing's  token address  ��������Ʒ���Һ�Լ��ַ
          uint256 token_num; //the amount of withing to exchange thiing ��������Ʒ����
          uint256 price;  //the price of the things per unit ��Ʒ����
          string AttachInfo; //additional information ��ע�򸽼���Ϣ��
        }
  uint public SalesNum;    //�ҵ�����
 address public Manager; //�������Ա  
//uint public decimals=18;
  mapping(uint=>ExThingInfo)  public Sales; //����ҵ�����
  TokenERC20  ExChToken;   //���ö���Ϊ���Һ�Լ
 //���캯�����������Ա
function DeExChange(
         ) public {
        manager=msg.sender;    
}

/* Saler send the sale information and transfer the owner power to contract ���ҹҵ������ʲ�����������Ȩת�Ƹ����ܺ�Լ*/
  function Sale(address ThisToken,uint256 _token_num,uint256 Price,string Attachstr)  public returns (bool success){
        // ���Լת������Ȩ�����������еǼǡ�
             ExChToken=TokenERC20(ThisToken);
             ExChToken.save(this,_token_num);  //���Լת�ƴ�������������Ȩ
             Sales[SalesNum]=ExThingInfo(msg.sender,ExChToken,_token_num,Price, Attachstr);
              SalesNum+=1;
             return true;
     }
/* Buyer send money to the contract and get the Token. ��ҷ����ʽ�����ܺ�Լ���������Ӧ�����ʲ�����*/
  function Buy(uint SalesIndex,uint256 _token_num) payable public {
        // ���Լ�����ʽ𣬲���ô�������Ȩ�� 
           uint256 BalanceChange=msg.value-Sales[SalesIndex].price;  //��������
           require( BalanceChange>=0);   //����Ӧ���ڻ���0
           ExChToken=Sales[SalesIndex].Token;  //������Һ�ԼΪ��ǰ���۴��ҡ�
           ExChToken.transfer(msg.sender,_token_num);  //�����ת�ƴ�������������Ȩ
           Sales[SalesIndex].owner.transfer(Sales[SalesIndex].price*99/100);  //������֧��99%����
           manager.transfer(Sales[SalesIndex].price*1/100);  //���׹����ʺ�֧��1%����
           delete Sales[SalesIndex];   //ɾ������
           SalesNum-=1;  //����������1
           if (BalanceChange>0) {                   //�����ʣ�࣬��������㡣
                msg.sender.transfer(BalanceChange);    
           }
      }
function Withdraw(uint SalesIndex) public {
        // ָ�������ţ������ҳ��ء� 
           require(Sales[SalesIndex].owner==msg.sender);   //ֻ�����������߲��ܳ�����
           ExChToken=Sales[SalesIndex].Token;
           ExChToken.transfer(msg.sender,Sales[SalesIndex].amount);  //����Լ�еĴ�����Ʒ���������ߡ�
           delete Sales[SalesIndex]; //������������ɾ��������.
           SalesNum-=1;
      } 
}

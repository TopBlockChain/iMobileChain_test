pragma solidity ^0.4.18;
/*�������裺
1�����𱾺�Լ��
2����ñ���Լ�ĺ�Լ��ַ����Ӧ�ÿ�ص��ڿ��ַ��Ϊ����Լ��ַ��
3�����û����ʻ���Ϊ0��ʹ���Ƽ�����Refering�����ʺţ�Ҫ�����ʺ����Ϊ0���Ǽǣ�
4����ʹ��Mine�����ڿ�,�����Ƽ��˽�Ϊ���Ƽ��˽���10%��Ϊ�Ƽ��˵��ϼ���������5%(���У���Ϊ��ؽ���1%�����ཱ�����󹤣�
*/
//����ȼ�ϼ�ע��Լ�еı���
contract MinerRefuel{
      mapping (address => uint) public MinerRefuelTime;   //�����ƶ�������ʱ��Mapping ����
      mapping (address => address) public MinerRefuelPool;   //�����ƶ�������ʱ��Mapping ����
}
//�ƶ��û��ڿ��Լ
contract MobileMine {
    //Define the Manager  �����Լ����Ա
     address public Manager;
     //��App����ʾ����
     bool public ShowInApp;
     //����ת���¼�
     event Transfer(address indexed from, address indexed to, uint256 value);
    //Only manager can modify. �������κ���������Լ����Ա���޸� 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
//Active users' information. �����Ծ�û����ݽṹ
    struct ActiveInfo {
          uint LastTime;     //Last calculate time. �ϴλ�Ծ�û�ͳ��ʱ��
          uint Users; //the number of already ActiveUsers since lasttime calculate. ��Ծ�û�����
        }
  /*Miner and active users defining  �����Ծ�û���������ActiveUsers*/
  ActiveInfo public ActiveUsers;
  mapping(address=>uint) Miners;   //�����ƶ���Mapping���飬���ڴ洢����Ľ���֧��ʱ��
  mapping(address=>address)  public Referees; //����󹤵��Ƽ���
  uint public RecFoundation;    //���屾��Լ���յ���ֱ��ת����ܶ�
  uint MineAmount;    //������ʱ���������ڼ���󹤵Ľ���֧����
  uint MinerRefTime;    //���ñ���:����������ע��Լ�е�����ʱ�䣬��Ҫ����������ע��Լ��ȡ  
  address MinerRefPool; 
 MinerRefuel MinerRef;   //���ö���Ϊ������ע��Լ
 
  //Constuct function��initially define the creator as the manager. ���캯�����������ԱΪ��Լ�����ߣ���ʼ���û�Ծ�����������ֵ������ע���Լ�ĺ�Լ��ַ��
   function MobileMine() public {
           Manager=msg.sender;
           ShowInApp = false; //Ĭ��Ϊ����ʾ���ɸ�����Ҫ�޸�
           ActiveUsers=ActiveInfo(now,0);     //�����Ծ�󹤱�������Ծ�û�ͳ��ʱ��Ϊ��ǰ�����ʱ�䣬��Ծ�û���Ϊ1��
           MinerRef=MinerRefuel(0x8C00B660792b235d4382368299E77C8c04ED4754);     //�Ǽ�ע���Լ�ĺ�Լ��ַ��������ע���Լ������ʹ��
    }
    //����ShowInApp
    function setShowInApp(bool b) onlyManager public {
           ShowInApp=b;
    }
  //Management power transfer. ��Լ����Ȩת�ƣ�������Ա�ܲ�����
  function transferManagement(address newManager) onlyManager public {
           Manager=newManager;
   }
//Define the contract can receive mining reward foundation. ����Լ���յ���ת��������ۼӡ�
   function () payable public {
         RecFoundation+=msg.value; 
   }
//�Ƽ���������¼���Ƽ���
  function Refering(address _newMiner) public {
        require(_newMiner.balance==0);  //��Ҫ�¿�δ���Ƽ������������Ϊ0��
        Referees[_newMiner]=msg.sender;      //���¿󹤵��Ƽ�������Ϊ��Ϣ������
    }

/* Miner mine function, modify miner's status �ƶ����ڿ������������������ƶ����ܲ���*/
  function Mine() public returns (bool success){
        //Pay the reward and change the miner's status. ���֧�����������޸Ŀ󹤵�Mapping�洢�ڿ�״̬��
         if(ActiveUsers.LastTime+86400<now){     //���ͳ��ʱ���ѳ���һ��
                  ActiveUsers.LastTime=now;    //���û�Ծ�û�ͳ��ʱ��Ϊ��ǰʱ��
                  ActiveUsers.Users=1;    //���û�Ծ�û���Ϊ1p
         }else{    //���ͳ��ʱ��δ����һ��
                 ActiveUsers.Users+=1;   //�ۼӻ�Ծ�û�����
         }
        MinerRefTime=MinerRef.MinerRefuelTime (msg.sender);   //����ע���Լ��������ȡ���ں�Լ�е�ע��ʱ��
        MinerRefPool=MinerRef.MinerRefuelPool (msg.sender);   //����ע���Լ��������ȡ���ں�Լ�е�ע����
        require (MinerRefTime+3600>now&&Miners[msg.sender]+86400<now&&MinerRefPool==address(this));   //Ҫ��������������������ע��Լ������ʱ����δ����1Сʱ���ڱ��������ȡ�����ѳ���һ�졣
        MineAmount=this.balance/(ActiveUsers.Users+10)*(now+1-ActiveUsers.LastTime)/86400;   //����󹤵Ľ�������ǰ��Լ�ʻ������Ե�ǰ�ѵǼǵĻ�Ծ�û��������Ե�ǰʱ����һ��ʱ���еı�����
        if  (Referees[msg.sender]!=0x0){   //�������Ƽ��ˣ���ִ���Ƽ��˽�����
            Referees[msg.sender].transfer(MineAmount/10);  //���ֱ���Ƽ��˽���10%.
            Transfer(this,Referees[msg.sender],MineAmount/10);//���ֱ���Ƽ���ת���¼�
            MineAmount-=MineAmount/10;  //�۳�ֱ���Ƽ��˽���
                if  (Referees[Referees[msg.sender]]!=0x0){   //�������Ƽ��ˣ���ִ���Ƽ��˽�����
                    Referees[Referees[msg.sender]].transfer(MineAmount/20);  //��󹤼���Ƽ��˽���5%.
                    Transfer(this,Referees[Referees[msg.sender]],MineAmount/20);  //��󹤼���Ƽ���ת���¼�
                    MineAmount-=MineAmount/20;//�۳�����Ƽ��˽���
                }
         }
         Manager.transfer(MineAmount/100);     //pay the manager the minerpool reward. ���ع���Ա�ʺ�֧����ǰ��Լ����1%����ֵ�ɵ�����
         Transfer(this, Manager, this.balance/100); //ת���¼����档
         MineAmount-=MineAmount/100;//�۳���ؽ���
         msg.sender.transfer(MineAmount);   //֧������
         Transfer(this, msg.sender, MineAmount); //ת���¼����档
         Miners[msg.sender]=now;    //�����ƶ��󹤵�֧��״̬Ϊ��ǰʱ��
       //Check if the calculating time of active user is lasting one day or not. ����Ծ�û���ͳ��ʱ���Ƿ��ѵ�һ��
        return true;
  }
} 



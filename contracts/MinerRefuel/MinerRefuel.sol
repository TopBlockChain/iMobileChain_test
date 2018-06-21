pragma solidity ^0.4.18;
//�ƶ���������ע��Լ
contract MinerRefuel {
  //�����Լ����Ա
    address public Manager;
    //Only manager can modify. 
   //����ת���¼� 
   event Transfer(address indexed from, address indexed to, uint256 value);
   //�������κ���������Լ����Ա���޸�
        modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }

//EnergyStation Manager Information.
//��������վ����Ա�����ݽṹ
   struct EnergyStation {
         bool status;      //����վ������Ա��״̬��ʹ�ܻ�ȥ������״̬��ʹ��TRUE��ȥ��FALSE
         string AppAddr;   //����վ������Ա���ĸ�����Ϣ������Ϊ����/IP��ַ�ȡ�
}
 
 uint public ReceiveFoundation;    //Having received reward foundation.  ����Լ�յ���ת���ܶ�
 mapping (address=>EnergyStation) public EnergyStations;     //��������վMapping����
 mapping (address => uint) public MinerRefuelTime;   //�����ƶ�������ʱ��Mapping ����
   //Only EnergyStation manager can modify. �������κ�����������վ������Ա���ʺ����޸ġ�
     modifier onlyEnergyStation {
         require(EnergyStations[msg.sender].status ==true);    //����վ������Ա���ʺŵ�״̬ΪTRUEʱ
         _;
      }
    //Construction function, initially define the creator as the manager.  ���캯������ʼ���ú�Լ������Ϊ����Ա
    function MinerRefuel() public {
            Manager=msg.sender;
    }
//Define the contract can receive mining reward foundation. ���屾��Լ�ɽ���ת���
   function () payable public {
         ReceiveFoundation+=msg.value;    //ת������ݲ����ۼӣ�����ReceiveFoundation�������� 
   }
//Management power thansfer. ����Ȩת�ƣ������ɵ�ǰ��Լ����Ա����
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
   //EnergyStation manager setting, only manager can modify.  ����վ������Ա�����ã������ɵ�ǰ����Ա������
   function EnergyStationSet(address energystation,bool status,string AppAddr) onlyManager public {
        EnergyStations[energystation]=EnergyStation(status,AppAddr);    //������վ������Ա�����ݽṹ��ֵ��״̬��IP��������ַ
    }
   //Miner refuel time setting , only Energy Station manager  can modify.  //�ƶ���������ע������������վ������Ա��������
   function Refuel(address Miner) onlyEnergyStation public {
        MinerRefuelTime[Miner]=now;      //���ÿ�����ʱ��Ϊ��ǰʱ��
        if (Miner.balance<10000000000000000){      //������ƶ��󹤵��ʻ����С��0.01APC
             Miner.transfer(10000000000000000);       //���ƶ����ʻ�ת��0.01APC
             Transfer(this, Miner, 10000000000000000); //ת���¼����档
        }
    }
}
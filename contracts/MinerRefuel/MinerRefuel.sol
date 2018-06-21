pragma solidity ^0.4.18;
//移动矿工能量加注合约
contract MinerRefuel {
  //定义合约管理员
    address public Manager;
    //Only manager can modify. 
   //定义转帐事件 
   event Transfer(address indexed from, address indexed to, uint256 value);
   //定义修饰函数：仅合约管理员能修改
        modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }

//EnergyStation Manager Information.
//定义能量站管理员的数据结构
   struct EnergyStation {
         bool status;      //能量站（管理员）状态：使能或去能两种状态，使能TRUE，去能FALSE
         string AppAddr;   //能量站（管理员）的附加信息，可设为域名/IP地址等。
}
 
 uint public ReceiveFoundation;    //Having received reward foundation.  本合约收到的转款总额
 mapping (address=>EnergyStation) public EnergyStations;     //定义能量站Mapping数组
 mapping (address => uint) public MinerRefuelTime;   //定义移动矿工能量时间Mapping 数组
   //Only EnergyStation manager can modify. 定义修饰函数：仅能量站（管理员）帐号能修改。
     modifier onlyEnergyStation {
         require(EnergyStations[msg.sender].status ==true);    //能量站（管理员）帐号的状态为TRUE时
         _;
      }
    //Construction function, initially define the creator as the manager.  构造函数，初始设置合约创建者为管理员
    function MinerRefuel() public {
            Manager=msg.sender;
    }
//Define the contract can receive mining reward foundation. 定义本合约可接受转入款
   function () payable public {
         ReceiveFoundation+=msg.value;    //转入款数据采用累加，计入ReceiveFoundation公共变量 
   }
//Management power thansfer. 管理权转移，仅能由当前合约管理员操作
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
   //EnergyStation manager setting, only manager can modify.  能量站（管理员）设置，仅能由当前管理员操作。
   function EnergyStationSet(address energystation,bool status,string AppAddr) onlyManager public {
        EnergyStations[energystation]=EnergyStation(status,AppAddr);    //对能量站（管理员）数据结构赋值：状态与IP或域名地址
    }
   //Miner refuel time setting , only Energy Station manager  can modify.  //移动矿工能量加注，仅能由能量站（管理员）操作。
   function Refuel(address Miner) onlyEnergyStation public {
        MinerRefuelTime[Miner]=now;      //设置矿工能量时间为当前时间
        if (Miner.balance<10000000000000000){      //如果该移动矿工的帐户余额小于0.01APC
             Miner.transfer(10000000000000000);       //向移动矿工帐户转款0.01APC
             Transfer(this, Miner, 10000000000000000); //转帐事件报告。
        }
    }
}
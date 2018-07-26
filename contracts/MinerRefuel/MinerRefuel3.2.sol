pragma solidity ^0.4.18;
//第三代移动认证合约

contract MinerRefuel {
  //变量定义
mapping (uint=>string) public Questions;     //定义能量加注站Mapping数组
mapping (uint=>uint[100])  Anwsers;     //定义能量加注站Mapping数组
mapping (uint=>address)  public Coinbases;     //定义能量加注站Mapping数组
mapping (address =>uint) public MinerRefuelTime;   //定义矿工注册时间数组
mapping (address =>address) public MinerRefuelPool;   //定义矿工矿池数组
 //问题注册，仅能由当前区码的矿工注册问
  function QuestionRegistry(string _Question,uint[100] _Anwser) public {
        require(msg.sender==block.coinbase);   //要 求出题人为当前矿工
        Questions[block.number]=_Question;   //注册问题
        Anwsers[block.number]=_Anwser;   //注册问题
        Coinbases[block.number]=block.coinbase; //注册出题矿工
        
   }
   // 矿工注册，要求执行一系列的验证操作mapping (uint=>bytes32[100])  Questions;     //定义能量加注站Mapping数组

   function MinerRegistry(uint _QuestionNum,uint _randnum,address pool,string _anwser) public {
        require(MinerRefuelTime[msg.sender]+3600<now);   //要求矿工在1小时内未注册过
        require(pool!=Coinbases[_QuestionNum]);// 要求所注册矿池不能是出题的矿工
        require(_randnum==uint(100*uint8(keccak256(_QuestionNum,msg.sender))/256));
        require(Anwsers[_QuestionNum][_randnum]==uint32(keccak256(Questions[_QuestionNum],_anwser)));
        MinerRefuelPool[msg.sender]=pool;     //设置矿工所注册的矿池
        MinerRefuelTime[msg.sender]=now;      //设置注册时间为当前时间
    }
}
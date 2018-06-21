// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package MinerRefuel

import (
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

var(
	PosConn *ethclient.Client
	PosMinerContractAddr = common.HexToAddress ("0x8C00B660792b235d4382368299E77C8c04ED4754")     //POSMINER合约地址
)	

// MinerRefuelABI is the input ABI used to generate the binding from.
const MinerRefuelABI = "[{\"constant\":false,\"inputs\":[{\"name\":\"energystation\",\"type\":\"address\"},{\"name\":\"status\",\"type\":\"bool\"},{\"name\":\"AppAddr\",\"type\":\"string\"}],\"name\":\"EnergyStationSet\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"Miner\",\"type\":\"address\"}],\"name\":\"Refuel\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"Manager\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"EnergyStations\",\"outputs\":[{\"name\":\"status\",\"type\":\"bool\"},{\"name\":\"AppAddr\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"MinerRefuelTime\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"ReceiveFoundation\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"newManager\",\"type\":\"address\"}],\"name\":\"transferManagement\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"fallback\"}]"

// MinerRefuelBin is the compiled bytecode used for deploying new contracts.
const MinerRefuelBin = `{
	"linkReferences": {},
	"object": "6060604052341561000f57600080fd5b336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506107228061005e6000396000f300606060405260043610610083576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063129ef5dd1461009557806318d631431461011c57806378357e53146101555780637fa8244c146101aa5780638ff894a014610284578063a22eef56146102d1578063e4edf852146102fa575b34600160008282540192505081905550005b34156100a057600080fd5b61011a600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035151590602001909190803590602001908201803590602001908080601f01602080910402602001604051908101604052809392919081815260200183838082843782019150505050505091905050610333565b005b341561012757600080fd5b610153600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610429565b005b341561016057600080fd5b610168610540565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34156101b557600080fd5b6101e1600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610565565b6040518083151515158152602001806020018281038252838181546001816001161561010002031660029004815260200191508054600181600116156101000203166002900480156102745780601f1061024957610100808354040283529160200191610274565b820191906000526020600020905b81548152906001019060200180831161025757829003601f168201915b5050935050505060405180910390f35b341561028f57600080fd5b6102bb600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610595565b6040518082815260200191505060405180910390f35b34156102dc57600080fd5b6102e46105ad565b6040518082815260200191505060405180910390f35b341561030557600080fd5b610331600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919050506105b3565b005b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561038e57600080fd5b6040805190810160405280831515815260200182815250600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008201518160000160006101000a81548160ff0219169083151502179055506020820151816001019080519060200190610420929190610651565b50905050505050565b60011515600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000160009054906101000a900460ff16151514151561048b57600080fd5b42600360008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002081905550662386f26fc100008173ffffffffffffffffffffffffffffffffffffffff1631101561053d578073ffffffffffffffffffffffffffffffffffffffff166108fc662386f26fc100009081150290604051600060405180830381858888f19350505050151561053c57600080fd5b5b50565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60026020528060005260406000206000915090508060000160009054906101000a900460ff169080600101905082565b60036020528060005260406000206000915090505481565b60015481565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561060e57600080fd5b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061069257805160ff19168380011785556106c0565b828001600101855582156106c0579182015b828111156106bf5782518255916020019190600101906106a4565b5b5090506106cd91906106d1565b5090565b6106f391905b808211156106ef5760008160009055506001016106d7565b5090565b905600a165627a7a723058203308a2599a4a15d32ee444a26e756deaac5d2192a9893d9ee4e4f64612e82be80029",
	"opcodes": "PUSH1 0x60 PUSH1 0x40 MSTORE CALLVALUE ISZERO PUSH2 0xF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST CALLER PUSH1 0x0 DUP1 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF MUL NOT AND SWAP1 DUP4 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND MUL OR SWAP1 SSTORE POP PUSH2 0x722 DUP1 PUSH2 0x5E PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN STOP PUSH1 0x60 PUSH1 0x40 MSTORE PUSH1 0x4 CALLDATASIZE LT PUSH2 0x83 JUMPI PUSH1 0x0 CALLDATALOAD PUSH29 0x100000000000000000000000000000000000000000000000000000000 SWAP1 DIV PUSH4 0xFFFFFFFF AND DUP1 PUSH4 0x129EF5DD EQ PUSH2 0x95 JUMPI DUP1 PUSH4 0x18D63143 EQ PUSH2 0x11C JUMPI DUP1 PUSH4 0x78357E53 EQ PUSH2 0x155 JUMPI DUP1 PUSH4 0x7FA8244C EQ PUSH2 0x1AA JUMPI DUP1 PUSH4 0x8FF894A0 EQ PUSH2 0x284 JUMPI DUP1 PUSH4 0xA22EEF56 EQ PUSH2 0x2D1 JUMPI DUP1 PUSH4 0xE4EDF852 EQ PUSH2 0x2FA JUMPI JUMPDEST CALLVALUE PUSH1 0x1 PUSH1 0x0 DUP3 DUP3 SLOAD ADD SWAP3 POP POP DUP2 SWAP1 SSTORE POP STOP JUMPDEST CALLVALUE ISZERO PUSH2 0xA0 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x11A PUSH1 0x4 DUP1 DUP1 CALLDATALOAD PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND SWAP1 PUSH1 0x20 ADD SWAP1 SWAP2 SWAP1 DUP1 CALLDATALOAD ISZERO ISZERO SWAP1 PUSH1 0x20 ADD SWAP1 SWAP2 SWAP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP3 ADD DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP1 DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP4 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP4 DUP4 DUP1 DUP3 DUP5 CALLDATACOPY DUP3 ADD SWAP2 POP POP POP POP POP POP SWAP2 SWAP1 POP POP PUSH2 0x333 JUMP JUMPDEST STOP JUMPDEST CALLVALUE ISZERO PUSH2 0x127 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x153 PUSH1 0x4 DUP1 DUP1 CALLDATALOAD PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND SWAP1 PUSH1 0x20 ADD SWAP1 SWAP2 SWAP1 POP POP PUSH2 0x429 JUMP JUMPDEST STOP JUMPDEST CALLVALUE ISZERO PUSH2 0x160 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x168 PUSH2 0x540 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP3 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE ISZERO PUSH2 0x1B5 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x1E1 PUSH1 0x4 DUP1 DUP1 CALLDATALOAD PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND SWAP1 PUSH1 0x20 ADD SWAP1 SWAP2 SWAP1 POP POP PUSH2 0x565 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP4 ISZERO ISZERO ISZERO ISZERO DUP2 MSTORE PUSH1 0x20 ADD DUP1 PUSH1 0x20 ADD DUP3 DUP2 SUB DUP3 MSTORE DUP4 DUP2 DUP2 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 ISZERO PUSH2 0x274 JUMPI DUP1 PUSH1 0x1F LT PUSH2 0x249 JUMPI PUSH2 0x100 DUP1 DUP4 SLOAD DIV MUL DUP4 MSTORE SWAP2 PUSH1 0x20 ADD SWAP2 PUSH2 0x274 JUMP JUMPDEST DUP3 ADD SWAP2 SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 JUMPDEST DUP2 SLOAD DUP2 MSTORE SWAP1 PUSH1 0x1 ADD SWAP1 PUSH1 0x20 ADD DUP1 DUP4 GT PUSH2 0x257 JUMPI DUP3 SWAP1 SUB PUSH1 0x1F AND DUP3 ADD SWAP2 JUMPDEST POP POP SWAP4 POP POP POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE ISZERO PUSH2 0x28F JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x2BB PUSH1 0x4 DUP1 DUP1 CALLDATALOAD PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND SWAP1 PUSH1 0x20 ADD SWAP1 SWAP2 SWAP1 POP POP PUSH2 0x595 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP3 DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE ISZERO PUSH2 0x2DC JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x2E4 PUSH2 0x5AD JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP3 DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE ISZERO PUSH2 0x305 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x331 PUSH1 0x4 DUP1 DUP1 CALLDATALOAD PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND SWAP1 PUSH1 0x20 ADD SWAP1 SWAP2 SWAP1 POP POP PUSH2 0x5B3 JUMP JUMPDEST STOP JUMPDEST PUSH1 0x0 DUP1 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND CALLER PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND EQ ISZERO ISZERO PUSH2 0x38E JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH1 0x40 DUP1 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 DUP4 ISZERO ISZERO DUP2 MSTORE PUSH1 0x20 ADD DUP3 DUP2 MSTORE POP PUSH1 0x2 PUSH1 0x0 DUP6 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 PUSH1 0x0 DUP3 ADD MLOAD DUP2 PUSH1 0x0 ADD PUSH1 0x0 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH1 0xFF MUL NOT AND SWAP1 DUP4 ISZERO ISZERO MUL OR SWAP1 SSTORE POP PUSH1 0x20 DUP3 ADD MLOAD DUP2 PUSH1 0x1 ADD SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0x420 SWAP3 SWAP2 SWAP1 PUSH2 0x651 JUMP JUMPDEST POP SWAP1 POP POP POP POP POP JUMP JUMPDEST PUSH1 0x1 ISZERO ISZERO PUSH1 0x2 PUSH1 0x0 CALLER PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 PUSH1 0x0 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH1 0xFF AND ISZERO ISZERO EQ ISZERO ISZERO PUSH2 0x48B JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST TIMESTAMP PUSH1 0x3 PUSH1 0x0 DUP4 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 DUP2 SWAP1 SSTORE POP PUSH7 0x2386F26FC10000 DUP2 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND BALANCE LT ISZERO PUSH2 0x53D JUMPI DUP1 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH2 0x8FC PUSH7 0x2386F26FC10000 SWAP1 DUP2 ISZERO MUL SWAP1 PUSH1 0x40 MLOAD PUSH1 0x0 PUSH1 0x40 MLOAD DUP1 DUP4 SUB DUP2 DUP6 DUP9 DUP9 CALL SWAP4 POP POP POP POP ISZERO ISZERO PUSH2 0x53C JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST JUMPDEST POP JUMP JUMPDEST PUSH1 0x0 DUP1 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 JUMP JUMPDEST PUSH1 0x2 PUSH1 0x20 MSTORE DUP1 PUSH1 0x0 MSTORE PUSH1 0x40 PUSH1 0x0 KECCAK256 PUSH1 0x0 SWAP2 POP SWAP1 POP DUP1 PUSH1 0x0 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH1 0xFF AND SWAP1 DUP1 PUSH1 0x1 ADD SWAP1 POP DUP3 JUMP JUMPDEST PUSH1 0x3 PUSH1 0x20 MSTORE DUP1 PUSH1 0x0 MSTORE PUSH1 0x40 PUSH1 0x0 KECCAK256 PUSH1 0x0 SWAP2 POP SWAP1 POP SLOAD DUP2 JUMP JUMPDEST PUSH1 0x1 SLOAD DUP2 JUMP JUMPDEST PUSH1 0x0 DUP1 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND CALLER PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND EQ ISZERO ISZERO PUSH2 0x60E JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP1 PUSH1 0x0 DUP1 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF MUL NOT AND SWAP1 DUP4 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND MUL OR SWAP1 SSTORE POP POP JUMP JUMPDEST DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 PUSH1 0x1F ADD PUSH1 0x20 SWAP1 DIV DUP2 ADD SWAP3 DUP3 PUSH1 0x1F LT PUSH2 0x692 JUMPI DUP1 MLOAD PUSH1 0xFF NOT AND DUP4 DUP1 ADD OR DUP6 SSTORE PUSH2 0x6C0 JUMP JUMPDEST DUP3 DUP1 ADD PUSH1 0x1 ADD DUP6 SSTORE DUP3 ISZERO PUSH2 0x6C0 JUMPI SWAP2 DUP3 ADD JUMPDEST DUP3 DUP2 GT ISZERO PUSH2 0x6BF JUMPI DUP3 MLOAD DUP3 SSTORE SWAP2 PUSH1 0x20 ADD SWAP2 SWAP1 PUSH1 0x1 ADD SWAP1 PUSH2 0x6A4 JUMP JUMPDEST JUMPDEST POP SWAP1 POP PUSH2 0x6CD SWAP2 SWAP1 PUSH2 0x6D1 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST PUSH2 0x6F3 SWAP2 SWAP1 JUMPDEST DUP1 DUP3 GT ISZERO PUSH2 0x6EF JUMPI PUSH1 0x0 DUP2 PUSH1 0x0 SWAP1 SSTORE POP PUSH1 0x1 ADD PUSH2 0x6D7 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST SWAP1 JUMP STOP LOG1 PUSH6 0x627A7A723058 KECCAK256 CALLER ADDMOD LOG2 MSIZE SWAP11 0x4a ISZERO 0xd3 0x2e 0xe4 DIFFICULTY LOG2 PUSH15 0x756DEAAC5D2192A9893D9EE4E4F646 SLT 0xe8 0x2b 0xe8 STOP 0x29 ",
	"sourceMap": "60:2735:0:-;;;1376:71;;;;;;;;1429:10;1421:7;;:18;;;;;;;;;;;;;;;;;;60:2735;;;;;;"
}`

// DeployMinerRefuel deploys a new Ethereum contract, binding an instance of MinerRefuel to it.
func DeployMinerRefuel(auth *bind.TransactOpts, backend bind.ContractBackend) (common.Address, *types.Transaction, *MinerRefuel, error) {
	parsed, err := abi.JSON(strings.NewReader(MinerRefuelABI))
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	address, tx, contract, err := bind.DeployContract(auth, parsed, common.FromHex(MinerRefuelBin), backend)
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	return address, tx, &MinerRefuel{MinerRefuelCaller: MinerRefuelCaller{contract: contract}, MinerRefuelTransactor: MinerRefuelTransactor{contract: contract}}, nil
}

// MinerRefuel is an auto generated Go binding around an Ethereum contract.
type MinerRefuel struct {
	MinerRefuelCaller     // Read-only binding to the contract
	MinerRefuelTransactor // Write-only binding to the contract
}

// MinerRefuelCaller is an auto generated read-only Go binding around an Ethereum contract.
type MinerRefuelCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// MinerRefuelTransactor is an auto generated write-only Go binding around an Ethereum contract.
type MinerRefuelTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// MinerRefuelSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type MinerRefuelSession struct {
	Contract     *MinerRefuel      // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// MinerRefuelCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type MinerRefuelCallerSession struct {
	Contract *MinerRefuelCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts      // Call options to use throughout this session
}

// MinerRefuelTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type MinerRefuelTransactorSession struct {
	Contract     *MinerRefuelTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts      // Transaction auth options to use throughout this session
}

// MinerRefuelRaw is an auto generated low-level Go binding around an Ethereum contract.
type MinerRefuelRaw struct {
	Contract *MinerRefuel // Generic contract binding to access the raw methods on
}

// MinerRefuelCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type MinerRefuelCallerRaw struct {
	Contract *MinerRefuelCaller // Generic read-only contract binding to access the raw methods on
}

// MinerRefuelTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type MinerRefuelTransactorRaw struct {
	Contract *MinerRefuelTransactor // Generic write-only contract binding to access the raw methods on
}

// NewMinerRefuel creates a new instance of MinerRefuel, bound to a specific deployed contract.
func NewMinerRefuel(address common.Address, backend bind.ContractBackend) (*MinerRefuel, error) {
	contract, err := bindMinerRefuel(address, backend, backend)
	if err != nil {
		return nil, err
	}
	return &MinerRefuel{MinerRefuelCaller: MinerRefuelCaller{contract: contract}, MinerRefuelTransactor: MinerRefuelTransactor{contract: contract}}, nil
}

// NewMinerRefuelCaller creates a new read-only instance of MinerRefuel, bound to a specific deployed contract.
func NewMinerRefuelCaller(address common.Address, caller bind.ContractCaller) (*MinerRefuelCaller, error) {
	contract, err := bindMinerRefuel(address, caller, nil)
	if err != nil {
		return nil, err
	}
	return &MinerRefuelCaller{contract: contract}, nil
}

// NewMinerRefuelTransactor creates a new write-only instance of MinerRefuel, bound to a specific deployed contract.
func NewMinerRefuelTransactor(address common.Address, transactor bind.ContractTransactor) (*MinerRefuelTransactor, error) {
	contract, err := bindMinerRefuel(address, nil, transactor)
	if err != nil {
		return nil, err
	}
	return &MinerRefuelTransactor{contract: contract}, nil
}

// bindMinerRefuel binds a generic wrapper to an already deployed contract.
func bindMinerRefuel(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(MinerRefuelABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_MinerRefuel *MinerRefuelRaw) Call(opts *bind.CallOpts, result interface{}, method string, params ...interface{}) error {
	return _MinerRefuel.Contract.MinerRefuelCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_MinerRefuel *MinerRefuelRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MinerRefuel.Contract.MinerRefuelTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_MinerRefuel *MinerRefuelRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _MinerRefuel.Contract.MinerRefuelTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_MinerRefuel *MinerRefuelCallerRaw) Call(opts *bind.CallOpts, result interface{}, method string, params ...interface{}) error {
	return _MinerRefuel.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_MinerRefuel *MinerRefuelTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MinerRefuel.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_MinerRefuel *MinerRefuelTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _MinerRefuel.Contract.contract.Transact(opts, method, params...)
}

// EnergyStations is a free data retrieval call binding the contract method 0x7fa8244c.
//
// Solidity: function EnergyStations( address) constant returns(status bool, AppAddr string)
func (_MinerRefuel *MinerRefuelCaller) EnergyStations(opts *bind.CallOpts, arg0 common.Address) (struct {
	Status  bool
	AppAddr string
}, error) {
	ret := new(struct {
		Status  bool
		AppAddr string
	})
	out := ret
	err := _MinerRefuel.contract.Call(opts, out, "EnergyStations", arg0)
	return *ret, err
}

// EnergyStations is a free data retrieval call binding the contract method 0x7fa8244c.
//
// Solidity: function EnergyStations( address) constant returns(status bool, AppAddr string)
func (_MinerRefuel *MinerRefuelSession) EnergyStations(arg0 common.Address) (struct {
	Status  bool
	AppAddr string
}, error) {
	return _MinerRefuel.Contract.EnergyStations(&_MinerRefuel.CallOpts, arg0)
}

// EnergyStations is a free data retrieval call binding the contract method 0x7fa8244c.
//
// Solidity: function EnergyStations( address) constant returns(status bool, AppAddr string)
func (_MinerRefuel *MinerRefuelCallerSession) EnergyStations(arg0 common.Address) (struct {
	Status  bool
	AppAddr string
}, error) {
	return _MinerRefuel.Contract.EnergyStations(&_MinerRefuel.CallOpts, arg0)
}

// Manager is a free data retrieval call binding the contract method 0x78357e53.
//
// Solidity: function Manager() constant returns(address)
func (_MinerRefuel *MinerRefuelCaller) Manager(opts *bind.CallOpts) (common.Address, error) {
	var (
		ret0 = new(common.Address)
	)
	out := ret0
	err := _MinerRefuel.contract.Call(opts, out, "Manager")
	return *ret0, err
}

// Manager is a free data retrieval call binding the contract method 0x78357e53.
//
// Solidity: function Manager() constant returns(address)
func (_MinerRefuel *MinerRefuelSession) Manager() (common.Address, error) {
	return _MinerRefuel.Contract.Manager(&_MinerRefuel.CallOpts)
}

// Manager is a free data retrieval call binding the contract method 0x78357e53.
//
// Solidity: function Manager() constant returns(address)
func (_MinerRefuel *MinerRefuelCallerSession) Manager() (common.Address, error) {
	return _MinerRefuel.Contract.Manager(&_MinerRefuel.CallOpts)
}

// MinerRefuelTime is a free data retrieval call binding the contract method 0x8ff894a0.
//
// Solidity: function MinerRefuelTime( address) constant returns(uint256)
func (_MinerRefuel *MinerRefuelCaller) MinerRefuelTime(opts *bind.CallOpts, arg0 common.Address) (*big.Int, error) {
	var (
		ret0 = new(*big.Int)
	)
	out := ret0
	err := _MinerRefuel.contract.Call(opts, out, "MinerRefuelTime", arg0)
	return *ret0, err
}

// MinerRefuelTime is a free data retrieval call binding the contract method 0x8ff894a0.
//
// Solidity: function MinerRefuelTime( address) constant returns(uint256)
func (_MinerRefuel *MinerRefuelSession) MinerRefuelTime(arg0 common.Address) (*big.Int, error) {
	return _MinerRefuel.Contract.MinerRefuelTime(&_MinerRefuel.CallOpts, arg0)
}

// MinerRefuelTime is a free data retrieval call binding the contract method 0x8ff894a0.
//
// Solidity: function MinerRefuelTime( address) constant returns(uint256)
func (_MinerRefuel *MinerRefuelCallerSession) MinerRefuelTime(arg0 common.Address) (*big.Int, error) {
	return _MinerRefuel.Contract.MinerRefuelTime(&_MinerRefuel.CallOpts, arg0)
}

// ReceiveFoundation is a free data retrieval call binding the contract method 0xa22eef56.
//
// Solidity: function ReceiveFoundation() constant returns(uint256)
func (_MinerRefuel *MinerRefuelCaller) ReceiveFoundation(opts *bind.CallOpts) (*big.Int, error) {
	var (
		ret0 = new(*big.Int)
	)
	out := ret0
	err := _MinerRefuel.contract.Call(opts, out, "ReceiveFoundation")
	return *ret0, err
}

// ReceiveFoundation is a free data retrieval call binding the contract method 0xa22eef56.
//
// Solidity: function ReceiveFoundation() constant returns(uint256)
func (_MinerRefuel *MinerRefuelSession) ReceiveFoundation() (*big.Int, error) {
	return _MinerRefuel.Contract.ReceiveFoundation(&_MinerRefuel.CallOpts)
}

// ReceiveFoundation is a free data retrieval call binding the contract method 0xa22eef56.
//
// Solidity: function ReceiveFoundation() constant returns(uint256)
func (_MinerRefuel *MinerRefuelCallerSession) ReceiveFoundation() (*big.Int, error) {
	return _MinerRefuel.Contract.ReceiveFoundation(&_MinerRefuel.CallOpts)
}

// EnergyStationSet is a paid mutator transaction binding the contract method 0x129ef5dd.
//
// Solidity: function EnergyStationSet(energystation address, status bool, AppAddr string) returns()
func (_MinerRefuel *MinerRefuelTransactor) EnergyStationSet(opts *bind.TransactOpts, energystation common.Address, status bool, AppAddr string) (*types.Transaction, error) {
	return _MinerRefuel.contract.Transact(opts, "EnergyStationSet", energystation, status, AppAddr)
}

// EnergyStationSet is a paid mutator transaction binding the contract method 0x129ef5dd.
//
// Solidity: function EnergyStationSet(energystation address, status bool, AppAddr string) returns()
func (_MinerRefuel *MinerRefuelSession) EnergyStationSet(energystation common.Address, status bool, AppAddr string) (*types.Transaction, error) {
	return _MinerRefuel.Contract.EnergyStationSet(&_MinerRefuel.TransactOpts, energystation, status, AppAddr)
}

// EnergyStationSet is a paid mutator transaction binding the contract method 0x129ef5dd.
//
// Solidity: function EnergyStationSet(energystation address, status bool, AppAddr string) returns()
func (_MinerRefuel *MinerRefuelTransactorSession) EnergyStationSet(energystation common.Address, status bool, AppAddr string) (*types.Transaction, error) {
	return _MinerRefuel.Contract.EnergyStationSet(&_MinerRefuel.TransactOpts, energystation, status, AppAddr)
}

// Refuel is a paid mutator transaction binding the contract method 0x18d63143.
//
// Solidity: function Refuel(Miner address) returns()
func (_MinerRefuel *MinerRefuelTransactor) Refuel(opts *bind.TransactOpts, Miner common.Address) (*types.Transaction, error) {
	return _MinerRefuel.contract.Transact(opts, "Refuel", Miner)
}

// Refuel is a paid mutator transaction binding the contract method 0x18d63143.
//
// Solidity: function Refuel(Miner address) returns()
func (_MinerRefuel *MinerRefuelSession) Refuel(Miner common.Address) (*types.Transaction, error) {
	return _MinerRefuel.Contract.Refuel(&_MinerRefuel.TransactOpts, Miner)
}

// Refuel is a paid mutator transaction binding the contract method 0x18d63143.
//
// Solidity: function Refuel(Miner address) returns()
func (_MinerRefuel *MinerRefuelTransactorSession) Refuel(Miner common.Address) (*types.Transaction, error) {
	return _MinerRefuel.Contract.Refuel(&_MinerRefuel.TransactOpts, Miner)
}

// TransferManagement is a paid mutator transaction binding the contract method 0xe4edf852.
//
// Solidity: function transferManagement(newManager address) returns()
func (_MinerRefuel *MinerRefuelTransactor) TransferManagement(opts *bind.TransactOpts, newManager common.Address) (*types.Transaction, error) {
	return _MinerRefuel.contract.Transact(opts, "transferManagement", newManager)
}

// TransferManagement is a paid mutator transaction binding the contract method 0xe4edf852.
//
// Solidity: function transferManagement(newManager address) returns()
func (_MinerRefuel *MinerRefuelSession) TransferManagement(newManager common.Address) (*types.Transaction, error) {
	return _MinerRefuel.Contract.TransferManagement(&_MinerRefuel.TransactOpts, newManager)
}

// TransferManagement is a paid mutator transaction binding the contract method 0xe4edf852.
//
// Solidity: function transferManagement(newManager address) returns()
func (_MinerRefuel *MinerRefuelTransactorSession) TransferManagement(newManager common.Address) (*types.Transaction, error) {
	return _MinerRefuel.Contract.TransferManagement(&_MinerRefuel.TransactOpts, newManager)
}

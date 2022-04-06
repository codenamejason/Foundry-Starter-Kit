pragma solidity ^0.7.6;
import "../foundry-tests/utils/Test.sol";
import "../interfaces/IUniswapV3Factory.sol";

import "../../contracts/UniswapV3Factory.sol";
import "../test/TestERC20.sol";
import "forge-std/Vm.sol";
string constant  v3factoryartifact = 'node_modules/@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json';

contract Deploy is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    

    function deployCode(string memory what) public returns (address addr) {
        bytes memory bytecode = vm.getCode(what);
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
      Check the configured workspace settings:
    }
}


contract factory is Deploy{
    
    TestERC20[] tokens;
    IUniswapV3Factory public ifcfactory;
    address constant bob= address(0x1337);
    address constant alice = address(0x1);

    function setUp() public {

        address _factory = deployCode(v3factoryartifact);
        ifcfactory = IUniswapV3Factory(_factory);
        
        address token0 = address(new TestERC20(1000*10**18));
        address token1 = address(new TestERC20(1000*10**18));
        tokens.push(TestERC20(token0));
        tokens.push(TestERC20(token1));
        vm.label(address(tokens[0]),"token 0 ");
        vm.label(address(tokens[1]),"token 1 ");
        vm.label(address(ifcfactory),"factory");
    }


    function testCreatePool() public {
        ///Expect working 
        assertTrue(address(tokens[0]) !=address(tokens[1]));
        address pool = ifcfactory.createPool(address(tokens[0]),address(tokens[1]),500);
        
        ///Expect revert cases!
        /// Same tokens case.
        vm.expectRevert();
        ifcfactory.createPool(address(tokens[0]),address(tokens[0]),500);
        
        // ///Check fee = 0 case. (tickSpacing= 0 )
        vm.expectRevert();
        ifcfactory.createPool(address(tokens[0]),address(tokens[1]),600);

        /// token0 = address(0) case.
        vm.expectRevert();
        ifcfactory.createPool(address(0),address(tokens[1]),500);

        // vm.expectEmit();
        // int24 tickspacing = ifcfactory.feeAmountTickSpacing(500); 
        // emit PoolCreated(address(tokens[0]),address(tokens[1]),500,tickspacing,pool);
        
        /// 
        vm.expectRevert();
        vm.prank(alice);
        ifcfactory.setOwner(address(bob));
        

        
    }

    function testsetOwner() public {
        /// Case: SetOwner where msg.sender != owner.
        vm.expectRevert();
        vm.prank(alice);
        ifcfactory.setOwner(address(bob));

        /// Case: SeOwner where msg.sender ==owner
        ifcfactory.setOwner(address(bob));

        
    }

    function testenableFeeAmount() public {
        /// Case: msg.sender!=owner
        vm.expectRevert();
        ifcfactory.enableFeeAmount(10000,16000);

        /// Case: msg.sender==owner, Fee > 1000000;
        vm.expectRevert();
        ifcfactory.enableFeeAmount(2000000,16000);

        /// Case: msg.sender==owner , tickSpacing > 16384;
         vm.expectRevert();
        ifcfactory.enableFeeAmount(10000,17000);

        /// Case: msg.sender==owner , tickSpacing ==0;
         vm.expectRevert();
        ifcfactory.enableFeeAmount(10000,0);

        /// Case: feeAmountTickSpacing  value already set for a particular fee value.
        /// Since Fee=500 already set in constructor .
         vm.expectRevert();
        ifcfactory.enableFeeAmount(10000,500);


    }




}

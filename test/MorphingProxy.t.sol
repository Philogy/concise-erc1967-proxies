// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";
import {MockImplementation} from "./mocks/MockImplementation.sol";
import {MorphingFactory} from "../src/MorphingFactory.sol";

/// @author philogy <https://github.com/philogy>
contract MorphingProxyTest is Test {
    address baseImpl;
    MorphingFactory factory;

    function setUp() public {
        baseImpl = address(new MockImplementation());
        factory = new MorphingFactory();
    }

    function testForwardCalls(uint256 _a) public {
        MockImplementation proxy = MockImplementation(_deployProxy(bytes32(0)));
        proxy.setA(_a);
        assertEq(uint256(vm.load(address(proxy), bytes32(0x0))), _a);
        assertEq(proxy.a(), _a);
    }

    function testBubbleUpError() public {
        MockImplementation proxy = MockImplementation(_deployProxy(bytes32(0)));
        vm.expectRevert(MockImplementation.MockError.selector);
        proxy.throwError();
    }

    function _deployProxy(bytes32 _salt) internal returns (address) {
        return factory.deployProxy(baseImpl, _salt);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {MockImplementation} from "./MockImplementation.sol";

/// @author philogy <https://github.com/philogy>
contract ERC1967UUPSTest is Test {
    address baseImpl;

    bytes32 constant ERC1967_IMPL_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    function setUp() public {
        baseImpl = address(new MockImplementation());
    }

    function testProxyCreation() public {
        address proxy = _deployUUPS();
        assertEq(
            address(uint160(uint256(vm.load(proxy, ERC1967_IMPL_SLOT)))),
            baseImpl
        );
    }

    function testForwardCall(uint256 _a) public {
        MockImplementation proxy = MockImplementation(_deployUUPS());
        proxy.setA(_a);
        assertEq(uint256(vm.load(address(proxy), bytes32(0x0))), _a);
    }

    function _deployUUPS() internal returns (address proxy) {
        proxy = HuffDeployer.config().with_args(abi.encode(baseImpl)).deploy(
            "ERC1967UUPS"
        );
    }
}

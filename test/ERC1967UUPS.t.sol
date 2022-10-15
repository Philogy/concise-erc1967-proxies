// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";
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

    function testForwardCalls(uint256 _a) public {
        MockImplementation proxy = MockImplementation(_deployUUPS());
        proxy.setA(_a);
        assertEq(uint256(vm.load(address(proxy), bytes32(0x0))), _a);
        assertEq(proxy.a(), _a);
    }

    function testBubbleUpError() public {
        MockImplementation proxy = MockImplementation(_deployUUPS());
        vm.expectRevert(MockImplementation.MockError.selector);
        proxy.throwError();
    }

    function _deployUUPS() internal returns (address proxy) {
        proxy = _deployHuff("src/ERC1967UUPS.huff", abi.encode(baseImpl), 0);
    }

    /// @dev Custom deploy huff method instead of `HuffDeployer` due to unknown
    /// issues
    function _deployHuff(
        string memory _fp,
        bytes memory _constructorArgs,
        uint256 _deployValue
    ) internal returns (address deployed) {
        string[] memory inputs = new string[](3);
        inputs[0] = "huffc";
        inputs[1] = "-b";
        inputs[2] = _fp;
        bytes memory baseCode = vm.ffi(inputs);
        bytes memory deployCode = bytes.concat(baseCode, _constructorArgs);
        assembly {
            deployed := create(
                _deployValue,
                add(deployCode, 0x20),
                mload(deployCode)
            )
        }
    }
}

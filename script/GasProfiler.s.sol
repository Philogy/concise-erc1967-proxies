// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {Script} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {deployJohnsProxy, deployProxy, compile, create, appendArg} from "./OtherDeployers.sol";
import {MorphingFactory} from "../src/MorphingFactory.sol";
import {MockImplementation} from "../test/MockImplementation.sol";

using {compile} for Vm;
using {create, appendArg} for bytes;

// taken from: https://github.com/libevm/hp2/blob/main/script/GasProfiler.s.sol
contract GasProfiler is Script {
    address johnsProxy;
    address libevmProxy;
    address philogyProxy;

    address impl;

    function setUp() public {
        impl = address(new MockImplementation());

        johnsProxy = deployJohnsProxy(vm, impl);
        libevmProxy = deployProxy(vm, impl, address(this));
        philogyProxy = new MorphingFactory().deployProxy(impl, bytes32(0));
    }

    function run() public {
        uint256 gasBefore;
        uint256 johnGasUsed;
        uint256 libevmGasUsed;
        uint256 philogyGasUsed;

        gasBefore = gasleft();
        MockImplementation(johnsProxy).setA(1);
        johnGasUsed = gasBefore - gasleft();

        gasBefore = gasleft();
        MockImplementation(libevmProxy).setA(1);
        libevmGasUsed = gasBefore - gasleft();

        gasBefore = gasleft();
        MockImplementation(philogyProxy).setA(1);
        philogyGasUsed = gasBefore - gasleft();

        console.log("MockImplementation.setA(1) gasProfiling");
        console.log("==============================");

        console.log("Jtriley's proxy gas used: ");
        console.log(johnGasUsed);
        console.log("====");
        console.log("Libevm proxy gas used: ");
        console.log(libevmGasUsed);
        console.log("====");
        console.log("Philogy proxy gas used: ");
        console.log(philogyGasUsed);
    }
}

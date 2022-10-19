// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;
import {IMorphingFactory} from "./IMorphingFactory.sol";

/// @author Philippe Dumonet <philippe@dumo.net>
contract MorphingProxyDeployer {
    constructor() payable {
        address implementation = IMorphingFactory(msg.sender)
            .getImplementation();
        bytes memory proxyCode = abi.encodePacked(
            hex"3373",
            msg.sender,
            hex"14610048573d3d363d3d373d3d363d73",
            implementation,
            hex"5af43d3d93803e61004657fd5bf35b33ff"
        );
        assembly {
            return(add(proxyCode, 0x20), mload(proxyCode))
        }
    }
}

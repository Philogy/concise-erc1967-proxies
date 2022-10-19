// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {IMorphingFactory} from "./IMorphingFactory.sol";
import {MorphingProxyDeployer} from "./MorphingProxyDeployer.sol";

/// @author Philippe Dumonet <philippe@dumo.net>
contract MorphingFactory is IMorphingFactory {
    address public getImplementation = address(uint160(1));

    mapping(address => address) public adminOf;
    mapping(address => bytes32) internal proxySalt;

    modifier onlyAdminOf(address _proxy) {
        if (adminOf[_proxy] != msg.sender) revert NotProxyAdmin();
        _;
    }

    modifier withImplementation(address _implementation) {
        getImplementation = _implementation;
        _;
        getImplementation = address(uint160(1));
    }

    function deployProxy(address _implementation, bytes32 _subSalt)
        external
        payable
        withImplementation(_implementation)
        returns (address proxy)
    {
        if (adminOf[_implementation] != address(0)) revert ProxyAlreadyExists();
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, _subSalt));
        proxy = address(new MorphingProxyDeployer{salt: salt}());
        proxySalt[proxy] = salt;
        adminOf[proxy] = msg.sender;
    }

    function changeAdminOf(address _proxy, address _newAdmin)
        external
        onlyAdminOf(_proxy)
    {
        adminOf[_proxy] = _newAdmin;
    }

    function upgrade(address _proxy, address _newImplementation)
        external
        payable
        onlyAdminOf(_proxy)
        withImplementation(_newImplementation)
    {
        _proxy.call(""); // cause self destruct
        new MorphingProxyDeployer{
            salt: proxySalt[_proxy],
            value: address(this).balance
        }(); // redeploy
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DataStreamsFeedFactory} from "../src/feed/DataStreamsFeedFactory.sol";

contract DeployDataStreamsFactory is Script {
    function run() external returns (address factoryAddress) {
        // The Verifier Proxy address for Monad Testnet
        address verifierProxyAddress = 0xC539169910DE08D237Df0d73BcDa9074c787A4a1;

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        DataStreamsFeedFactory factory = new DataStreamsFeedFactory(verifierProxyAddress);
        vm.stopBroadcast();
        
        factoryAddress = address(factory);
        console.log("DataStreamsFeedFactory deployed at:", factoryAddress);
    }
}

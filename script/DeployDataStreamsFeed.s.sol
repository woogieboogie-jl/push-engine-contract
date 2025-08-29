// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DataStreamsFeed} from "../src/feed/DataStreamsFeed.sol"; // Import the main contract

/**
 * @title Deployment Script for the original DataStreamsFeed
 * @dev Deploys a non-upgradeable instance of the DataStreamsFeed contract.
 * This script is for the contract version that uses local interfaces to discover the Fee Manager.
 */
contract DeployDataStreamsFeed is Script {
    function run() external returns (address deployedAddress) {
        // =================================================================
        // │                  CONFIGURATION PARAMETERS                     │
        // =================================================================

        // The official Chainlink Verifier Proxy address for your target chain.
        address verifierProxyAddress = 0xC539169910DE08D237Df0d73BcDa9074c787A4a1; // <-- TODO: Replace with official address

        // The unique ID for the Data Stream you want to track (e.g., ETH/USD).
        bytes32 feedId = 0x0008b3b5edb969383980724bea9a7b18064631ae69f981964cd8abc335c32680; // <-- TODO: Replace with the desired feed ID

        // The number of decimals for the price data.
        uint8 decimals = 18;

        // The maximum value for report expiration duration
        uint32 maxExpiration = 30 days;

        // A human-readable description for the feed.
        string memory description = "AMZN/USD";
        
        // =================================================================
        // │                        DEPLOYMENT LOGIC                       │
        // =================================================================
        
        // Start the broadcast. The next call will be a sent transaction.
        vm.startBroadcast();

        // Deploy the DataStreamsFeed contract in a single transaction.
        // We do NOT pass the feeManagerAddress, as the contract finds it itself.
        console.log("Deploying DataStreamsFeed (Community Driven)...");
        DataStreamsFeed feed = new DataStreamsFeed(
            verifierProxyAddress,
            feedId,
            decimals,
            maxExpiration,
            description
        );
        
        deployedAddress = address(feed);
        console.log("DataStreamsFeed deployed at:", deployedAddress);

        // Stop the broadcast.
        vm.stopBroadcast();

        return deployedAddress;
    }
}

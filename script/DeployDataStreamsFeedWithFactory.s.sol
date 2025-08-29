// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DataStreamsFeedFactory} from "../src/feed/DataStreamsFeedFactory.sol";

contract DeployDataStreamsFeedWithFactory is Script {
    // The struct remains the same
    struct FeedConfig {
        string name;
        string userSalt;
        string feedId;
        uint8 decimals;
        uint32 maxReportExpirationSeconds;
        string description;
        address admin;
        address updater;
    }

    function run() external {
        string memory configFileContents = vm.readFile("./script/deploy-config.json");

        address factoryAddress = vm.parseJsonAddress(configFileContents, ".factoryAddress");
        DataStreamsFeedFactory factory = DataStreamsFeedFactory(factoryAddress);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Processing feeds from config file...");
        uint256 newDeploysCount = 0;

        vm.startBroadcast(deployerPrivateKey);

        // CORRECTED: Iterate through the JSON array and parse each object individually
        for (uint i = 0; ; ++i) {
            string memory feedBasePath = string.concat(".feeds[", vm.toString(i), "]");

            // Use a try-catch to gracefully detect the end of the array.
            // If parsing a mandatory field like '.name' fails, we break the loop.
            try vm.parseJsonString(configFileContents, string.concat(feedBasePath, ".name")) {
                // This call is just to check for existence. The value is parsed below.
            } catch {
                // Reached the end of the feeds array, so exit the loop.
                break;
            }

            // Create and populate the struct by parsing each field
            FeedConfig memory feedConfig;
            feedConfig.name = vm.parseJsonString(configFileContents, string.concat(feedBasePath, ".name"));
            feedConfig.userSalt = vm.parseJsonString(configFileContents, string.concat(feedBasePath, ".userSalt"));
            feedConfig.feedId = vm.parseJsonString(configFileContents, string.concat(feedBasePath, ".feedId"));
            feedConfig.decimals = uint8(vm.parseJsonUint(configFileContents, string.concat(feedBasePath, ".decimals")));
            feedConfig.maxReportExpirationSeconds = uint32(vm.parseJsonUint(configFileContents, string.concat(feedBasePath, ".maxReportExpirationSeconds")));
            feedConfig.description = vm.parseJsonString(configFileContents, string.concat(feedBasePath, ".description"));
            feedConfig.admin = vm.parseJsonAddress(configFileContents, string.concat(feedBasePath, ".admin"));
            feedConfig.updater = vm.parseJsonAddress(configFileContents, string.concat(feedBasePath, ".updater"));

            // --- The rest of your deployment logic is unchanged ---

            bytes32 userSalt_b32 = vm.parseBytes32(feedConfig.userSalt);
            bytes32 feedId_b32 = vm.parseBytes32(feedConfig.feedId);

            address predictedAddress = factory.computeFeedAddress(
                deployerAddress,
                userSalt_b32,
                feedId_b32,
                feedConfig.decimals,
                feedConfig.maxReportExpirationSeconds,
                feedConfig.description
            );

            if (predictedAddress.code.length > 0) {
                console.log("--> Skipping '%s': Already deployed at %s", feedConfig.name, predictedAddress);
            } else {
                console.log("--> Deploying '%s'...", feedConfig.name);
                newDeploysCount++;

                address newFeedAddress = factory.createFeed(
                    userSalt_b32,
                    feedId_b32,
                    feedConfig.decimals,
                    feedConfig.maxReportExpirationSeconds,
                    feedConfig.description,
                    feedConfig.admin,
                    feedConfig.updater
                );

                require(newFeedAddress == predictedAddress, "Deployment address mismatch");
                console.log("    Success! Deployed '%s' to %s", feedConfig.name, newFeedAddress);
            }
        }

        vm.stopBroadcast();
        console.log("Deployment complete. Deployed %d new feed contracts.", newDeploysCount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface DataStreamsStructs {
    struct ReportV2 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 price; // DON consensus median price (8 or 18 decimals).
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v3 schema (crypto streams).
     * The `price`, `bid`, and `ask` values are carried to either 8 or 18 decimal places, depending on the stream.
     * For more information, see https://docs.chain.link/data-streams/crypto-streams and https://docs.chain.link/data-streams/reference/report-schema
     */
    struct ReportV3 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 price; // DON consensus median price (8 or 18 decimals).
        int192 bid; // Simulated price impact of a buy order up to the X% depth of liquidity utilisation (8 or 18 decimals).
        int192 ask; // Simulated price impact of a sell order up to the X% depth of liquidity utilisation (8 or 18 decimals).
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v4 schema (RWA streams).
     * The `price` value is carried to either 8 or 18 decimal places, depending on the stream.
     * The `marketStatus` indicates whether the market is currently open. Possible values: `0` (`Unknown`), `1` (`Closed`), `2` (`Open`).
     * For more information, see https://docs.chain.link/data-streams/rwa-streams and https://docs.chain.link/data-streams/reference/report-schema-v4
     */
    struct ReportV4 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 price; // DON consensus median benchmark price (8 or 18 decimals).
        uint32 marketStatus; // The DON's consensus on whether the market is currently open.
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v5 schema.
     * The `rate` value is carried to either 8 or 18 decimal places, depending on the stream.
     */
    struct ReportV5 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 rate; // DON consensus median rate (8 or 18 decimals).
        uint32 timestamp; // Timestamp for the rate data.
        uint32 duration; // Duration of the rate period.
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v6 schema.
     * Contains multiple price points for comprehensive market data.
     */
    struct ReportV6 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 price; // Primary price (8 or 18 decimals).
        int192 price2; // Secondary price (8 or 18 decimals).
        int192 price3; // Tertiary price (8 or 18 decimals).
        int192 price4; // Quaternary price (8 or 18 decimals).
        int192 price5; // Quinary price (8 or 18 decimals).
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v7 schema.
     * The `exchangeRate` value is carried to either 8 or 18 decimal places, depending on the stream.
     */
    struct ReportV7 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 exchangeRate; // DON consensus median exchange rate (8 or 18 decimals).
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v8 schema.
     * Contains market status and last update timestamp information.
     */
    struct ReportV8 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        uint64 lastUpdateTimestamp; // Timestamp of the last valid price update.
        int192 price; // DON consensus median price (8 or 18 decimals).
        uint32 marketStatus; // Market status (0 = Unknown, 1 = Closed, 2 = Open).
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v9 schema (NAV streams).
     * Contains NAV per share, AUM, and ripcord information.
     */
    struct ReportV9 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 benchmark; // DON consensus NAV per share (8 or 18 decimals).
        uint64 navDate; // Timestamp for the date the NAV Report was produced.
        int192 aum; // DON consensus for the total Assets Under management (8 or 18 decimals).
        uint32 ripcord; // Pause indicator (0 = normal, 1 = paused).
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v10 schema.
     * Contains multiplier and tokenized price information.
     */
    struct ReportV10 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain's native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        uint64 lastUpdateTimestamp; // Timestamp of the last valid price update.
        int192 price; // DON consensus median price (8 or 18 decimals).
        uint32 marketStatus; // Market status (0 = Unknown, 1 = Closed, 2 = Open).
        int192 currentMultiplier; // Current multiplier value.
        int192 newMultiplier; // New multiplier value.
        uint32 activationDateTime; // Activation date/time for the new multiplier.
        int192 tokenizedPrice; // Tokenized price value.
    }

    /// @notice The asset struct to hold the address of an asset and amount
    struct Asset {
        address assetAddress;
        uint256 amount;
    }
}

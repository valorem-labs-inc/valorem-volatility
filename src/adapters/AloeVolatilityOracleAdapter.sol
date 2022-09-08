// SPDX-License-Identifier: BUSL 1.1
pragma solidity 0.8.13;

import "../interfaces/IVolatilityOracleAdapter.sol";

import "../libraries/aloe/interfaces/IVolatilityOracle.sol";
import "../libraries/aloe/VolatilityOracle.sol";

import "v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";

import "solmate/auth/authorities/MultiRolesAuthority.sol";

/**
 * @notice This contract adapts the Aloe capital volatility oracle 
 * contract from https://github.com/aloelabs/aloe-blend.
 */
contract AloeVolatilityOracleAdapter is IVolatilityOracleAdapter, MultiRolesAuthority {
    IUniswapV3Factory private uniswapV3Factory;
    IVolatilityOracle private aloeVolatilityOracle;
    address private v3PoolTokenB;
    uint24 private v3PoolRate;

    constructor(address v3Factory, address aloeOracle)
        MultiRolesAuthority(msg.sender, Authority(address(0)))
    {
        setRoleCapability(0, AloeVolatilityOracleAdapter.setUniswapV3Pool.selector, true);
        uniswapV3Factory = IUniswapV3Factory(v3Factory);
        aloeVolatilityOracle = IVolatilityOracle(aloeOracle);
    }

    /**
     * @notice Retrieves the historical volatility of a ERC20 token.
     * @param token The ERC20 token for which to retrieve historical volatility.
     * @return historicalVolatility The historical volatility of the token, scaled by 1e18
     */
    function getHistoricalVolatility(address token) external view returns (uint256 historicalVolatility) {
        revert("AloeVolatilityOracle does not implement historical volatility");
        return 0;
    }

    /**
     * @notice Retrieves the implied volatility of a ERC20 token.
     * @param token The ERC20 token for which to retrieve implied volatility.
     * @return impliedVolatility The implied volatiltiy of the token, scaled by 1e18
     */
    function getImpliedVolatility(address token) external view returns (uint256 impliedVolatility) {
        IUniswapV3Pool pool = getV3PoolForTokenAddress(token);
        return 0;
    }

    /**
     * @notice Returns the scaling factor for the volatility
     * @return scale The power of 10 by which the return is scaled
     */
    function scale() external pure returns (uint16 scale) {
        return 18;
    }

    function getV3PoolForTokenAddress(address token) public view returns (IUniswapV3Pool pool) {
        address pool = uniswapV3Factory.getPool(token, v3PoolTokenB, v3PoolRate);
        return IUniswapV3Pool(pool);
    }

    /**
    /////////////// ADMIN FUNCTIONS ///////////////
     */
     // TODO: Handle if token is invalid/no pool available?
    function setUniswapV3Pool(address token, uint24 fee) external requiresAuth {
        v3PoolTokenB = token;
        v3PoolRate = fee;
    }

    function setAloeOracle(address oracle) external requiresAuth {
        aloeVolatilityOracle = IVolatilityOracle(oracle);
    }

    function setV3Factory(address factory) external requiresAuth {
        uniswapV3Factory = IUniswapV3Factory(factory);
    }
}
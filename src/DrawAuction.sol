// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import { PrizePool } from "v5-prize-pool/PrizePool.sol";

contract DrawAuction {
  uint32 internal _auctionDuration;

  constructor(uint32 auctionDuration_) {
    _auctionDuration = auctionDuration_;
  }

  /// @notice Allows the Manager to complete the current prize period and starts the next one, updating the number of tiers, the winning random number, and the prize pool reserve
  /// @param _prizePool The prize pool to complete
  /// @param winningRandomNumber_ The winning random number for the current draw
  function completeAndStartNextDraw(PrizePool _prizePool, uint256 winningRandomNumber_) external {
    uint256 _y = _reward(_prizePool);

    _prizePool.completeAndStartNextDraw(winningRandomNumber_);

    _prizePool.withdrawReserve(msg.sender, uint104(_y));
  }

  /// @notice Returns the current reward for the prize pool
  /// @param _prizePool The prize pool whose award should be checked
  /// @return the reward size
  function reward(PrizePool _prizePool) external view returns (uint256) {
    return _reward(_prizePool);
  }

  /// @notice Returns the current reward for the prize pool
  /// @param _prizePool The prize pool whose reward should be checked
  /// @return the reward size
  function _reward(PrizePool _prizePool) internal view returns (uint256) {
    uint256 _nextDrawEndsAt = _prizePool.nextDrawEndsAt();

    if (block.timestamp < _nextDrawEndsAt) {
      return 0;
    }

    uint256 _reserve = _prizePool.reserve() + _prizePool.reserveForNextDraw();
    uint256 _elapsedTime = block.timestamp - _nextDrawEndsAt;

    return
      _elapsedTime >= _auctionDuration ? _reserve : (_elapsedTime * _reserve) / _auctionDuration;
  }

  function auctionDuration() external view returns (uint256) {
    return _auctionDuration;
  }
}

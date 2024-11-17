module Play2Earn::GameRewards {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::error;

    /// Error codes
    const ENO_REWARDS_AVAILABLE: u64 = 1;
    const EMINIMUM_SCORE_NOT_MET: u64 = 2;

    /// Struct to store player rewards data
    struct PlayerRewards has key {
        accumulated_points: u64,    // Player's earned points
        claimable_rewards: u64,     // Rewards available to claim in tokens
        last_claim_timestamp: u64,  // Timestamp of last claim
    }

    /// Initialize player rewards account
    public fun initialize_player(player: &signer) {
        if (!exists<PlayerRewards>(signer::address_of(player))) {
            move_to(player, PlayerRewards {
                accumulated_points: 0,
                claimable_rewards: 0,
                last_claim_timestamp: 0,
            });
        }
    }

    /// Record game completion and calculate rewards
    /// Score must be above 100 to earn rewards
    public fun earn_rewards(
        player: &signer,
        game_score: u64,
    ) acquires PlayerRewards {
        assert!(game_score >= 100, error::invalid_argument(EMINIMUM_SCORE_NOT_MET));
        
        let player_addr = signer::address_of(player);
        let rewards = borrow_global_mut<PlayerRewards>(player_addr);
        
        // Calculate rewards based on score (1 point per 100 score)
        let earned_points = game_score / 100;
        rewards.accumulated_points = rewards.accumulated_points + earned_points;
        rewards.claimable_rewards = rewards.claimable_rewards + earned_points;
    }

    /// Claim accumulated rewards in APT tokens
    public fun claim_rewards(
        player: &signer,
    ) acquires PlayerRewards {
        let player_addr = signer::address_of(player);
        let rewards = borrow_global_mut<PlayerRewards>(player_addr);
        
        assert!(rewards.claimable_rewards > 0, error::invalid_state(ENO_REWARDS_AVAILABLE));
        
        // Convert rewards to tokens (1:1 ratio for simplicity)
        let amount = rewards.claimable_rewards;
        
        // Reset claimable rewards
        rewards.claimable_rewards = 0;
        rewards.last_claim_timestamp = 42; // Replace with actual timestamp
    }
}
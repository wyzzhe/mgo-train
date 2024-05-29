module tokens_examples::mycoin {
    use std::option;
    use mgo::coin::{Self, Coin, TreasuryCap};
    use mgo::transfer;
    use mgo::tx_context::{Self, TxContext};

    /// The name of the coin. By convention, this type has the same name as its parent module.
    /// And there are no fields. The complete coin type defined by this module will be `COIN<MYCOIN>`.
    struct MYCOIN has drop {}

    /// Sign up for managed currency to get it“TreasuryCap”。
    /// Because this is a module initializer, it ensures that the currency only gets registered once。
    fun init(witness: MYCOIN, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 6, b"MYCOIN", b"", b"", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }
    /// Admins can mint tokens
    public entry fun mint(
        treasury_cap: &mut TreasuryCap<MYCOIN>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    /// Administrators can destroy tokens
    public entry fun burn(treasury_cap: &mut TreasuryCap<MYCOIN>, coin: Coin<MYCOIN>) {
        coin::burn(treasury_cap, coin);
    }
}
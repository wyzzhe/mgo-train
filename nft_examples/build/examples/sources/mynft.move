module examples::mynft{
    use mgo::url::{Self, Url};
    use mgo::transfer;
    use mgo::object::{Self,ID, UID};
    use mgo::tx_context::{Self, TxContext};
    use mgo::package::{Self};
    use std::string::{Self,String};
    use mgo::display::{Self};

    struct NFT has key, store{
        id: UID,
        name: String,
        description: String,
        creator: address,
        url: Url,
    }
    struct MYNFT has drop{}

    // Add support for browser object display
    #[allow(lint(share_owned))]
    fun init (otw: MYNFT, ctx: &mut TxContext,){
        let publisher = package::claim(otw, ctx);
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"image_url"),
            string::utf8(b"description"),
            string::utf8(b"creator"),
        ];

        let values = vector[
            string::utf8(b"{name}"),
            string::utf8(b"{url}"),
            string::utf8(b"{description}"),
            string::utf8(b"{creator}")
        ];

        let display = display::new_with_fields<NFT>(
            &publisher, 
            keys,
            values,
            ctx,
        );

        display::update_version(&mut display);
        transfer::public_share_object(display);
        transfer::public_transfer(publisher, tx_context::sender(ctx))

    }

    // mint nft
    public entry fun mint(
        name: String,
        description: String,
        url:String,
        ctx: &mut TxContext,
    ){
        let nft = NFT{
            id: object::new(ctx),
            name: name,
            description: description,
            creator: tx_context::sender(ctx),
            url: url::new_unsafe(string::to_ascii(url)),
        };
        transfer::public_transfer(nft, tx_context::sender(ctx))
    }

    /// Transfer "nft" to "receiver"
    public entry fun transfer(
        nft: NFT, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient)
    }
    /// Update the description of "nft" to "new_description"
    public entry fun update_description(
        nft: &mut NFT,
        new_description: vector<u8>,
        _: &mut TxContext
    ) {
        nft.description = string::utf8(new_description)
    }

    /// Permanently delete "nft"
    public entry fun burn(nft: NFT, _: &mut TxContext) {
        let NFT { id, name: _, description: _, url: _ ,creator:_} = nft;
        object::delete(id)
    }
}
module nft_examples::mynft{
    use mgo::url::{Self, Url};
    use mgo::transfer;
    use mgo::object::{Self,ID, UID};
    use mgo::tx_context::{Self, TxContext};
    use mgo::package::{Self};
    use std::string::{Self,String};
    use mgo::display::{Self};

    // NFT是对象，有key，id是UID，也是资产，资产有key和store，资产可以被全局存储和转移
    struct NFT has key, store{
        id: UID,
        name: String,
        description: String,
        creator: address,
        url: Url,
    }
    // MYNFT用于一次性见证，一次性见证名字是模块名字的大写，只有drop能力
    struct MYNFT has drop{}

    // Add support for browser object display
    // NFT和Coin的区别：Coin有模版，NFT模版在代码里自己写
    #[allow(lint(share_owned))]
    fun init (otw: MYNFT, ctx: &mut TxContext,){
        // publisher字段 {id,package_address,module_name}
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
        // 共享的display Objects，使其在区块链上可见并可访问。
        transfer::public_share_object(display);
        // 把发布者发送给交易发起者，完成NFT发布者对象的发布和所有权转移
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
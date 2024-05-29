module nft_examples::mynft{
    use mgo::url::{Self, Url};
    use mgo::transfer;
    use mgo::object::{Self,ID, UID};
    // Self可以代替mgo::tx_context
    use mgo::tx_context::{Self, TxContext};
    use mgo::package::{Self};
    use std::string::{Self,String};
    use mgo::display::{Self};

    // MYNFT用于一次性见证，一次性见证名字是模块名字的大写，只有drop能力
    struct NFT has drop{}

    // NFT的类型
    struct MyNFT has key, store{
        id: UID,
        // 自增的字段id
        tokenId: u64
        // name: String,
        // description: String,
        // creator: address,
        // url: Url,
    }

    // NFT中心化存储,有人mint时知道下一个tokenId
    struct State has key {
        id: UID,
        count: u64
    }

    // Add support for browser object display
    // NFT和Coin的区别：Coin有模版，NFT模版在代码里自己写
    #[allow(lint(share_owned))]
    fun init (otw: NFT, ctx: &mut TxContext,){
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"collection"),
            string::utf8(b"image_url"),
            string::utf8(b"description"),
            // string::utf8(b"creator"),
        ];

        let values = vector[
            // tokenId 会变
            string::utf8(b"FixedDogNFT #{tokenId}"),
            string::utf8(b"FixedDogNFT collection"),
            // 每个tokenId生成的图片都不一样
            // string::utf8(b"https://mangonft.com/{tokenId}.png"),
            string::utf8(b"https://docs.devnet.mangonetwork.io/img/logo.svg"),
            string::utf8(b"This a set of DogNFT."),
            // string::utf8(b"ByWyz")
        ];

        // 用otw生成publisher；publisher字段 {id,package_address,module_name}
        let publisher = package::claim(otw, ctx);

        let display = display::new_with_fields<MyNFT>(
            &publisher, 
            keys,
            values,
            ctx,
        );
        // 每次更新display时要对其进行升级 display.version++ 发出version更新事件
        display::update_version(&mut display);
        // 把发布者发送给交易发起者，完成NFT发布者对象的发布和所有权转移
        // 资源具有key和store，必须明确所有权
        transfer::public_transfer(publisher, tx_context::sender(ctx))
        transfer::public_transfer(display, tx_context::sender(ctx))
        // 共享的display Objects，使其在区块链上可见并可访问。
        // transfer::public_share_object(display);

        // 编号Id，给后续的NFT一个tokenId
        transfer::share_object{State{
            id: object::new(ctx),
            count: 0,
        }}
    }

    // mint nft
    public entry fun mint(state: &mut State, ctx: &mut TxContext,){
        let sender = tx_context::sender(ctx);
        state.count = state.count + 1;

        let nft = MyNFT{
            id: object::new(ctx),
            tokenId: state.count,
        };
        transfer::public_transfer(nft, sender)
    }

    /// Transfer "nft" to "receiver"
    public entry fun transfer(
        nft: MyNFT, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient)
    }
    /// Update the description of "nft" to "new_description"
    public entry fun update_description(
        nft: &mut MyNFT,
        new_description: vector<u8>,
        _: &mut TxContext
    ) {
        nft.description = string::utf8(new_description)
    }

    /// Permanently delete "nft"
    public entry fun burn(nft: MyNFT, _: &mut TxContext) {
        let MyNFT { id, name: _, description: _, url: _ ,creator:_} = nft;
        object::delete(id)
    }
}
module nft_examples::nft_sbt{
    use std::string::{Self, String};
    use mgo::tx_context::{Self, TxContext};
    use mgo::package::{Self};
    use mgo::url::{Self, Url};
    use mgo::display::{Self};
    use mgo::object::{Self, ID, UID};
    use mgo::transfer;

    struct NFT_SBT has drop ()

    // 没有store，不能任意的被发送，只能由当前的模块来定义此NFT如何被发送，没写发送逻辑的话，NFT就无法被发送
    struct MySBT has key{
        id: UID,
        tokenId: u64,
    }

    struct State has key{
        id: UID,
        count: u64,
    }

    fun init(witness: NFT_SBT, ctx: &mut TxContext){
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"collection"),
            string::utf8(b"image_url"),
            string::utf8(b"description"),
        ];

        let values = vector[
            string::utf8(b"FixedDogSBT #{tokenId}"),
            string::utf8(b"FixedDogSBT collection"),
            string::utf8(b"https://docs.devnet.mangonetwork.io/img/logo.svg"),
            string::utf8(b"This a set of DogSBT."),
        ];

        let publisher = package::claim(witness, ctx);
        let display = display::new_with_fields<MySBT>[&publisher, keys, values, ctx];

        display::update_version(&mut display);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));

        transfer::share_object(State{
            id: object::new(ctx),
            count: 0,
        })
    }

    public entry fun mint(state: &mut State, ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        state.count = state.count + 1;
        let nft = MySBT {
            id: object::new(ctx),
            tokendId: state.count,
        };
        transfer::transfer(nft, sender);
    }
}
module tokens_examples::mycoin {
    use std::option;
    use mgo::coin::{Self, Coin, TreasuryCap};
    use mgo::transfer;
    use mgo::tx_context::{Self, TxContext};

    /// The name of the coin. By convention, this type has the same name as its parent module.
    /// And there are no fields. The complete coin type defined by this module will be `COIN<MYCOIN>`.
    /// 结构体类型 作用：当作一次性见证范型T使用 能力：drop
    struct MYCOIN has drop {}

    /// Sign up for managed currency to get it“TreasuryCap”。
    /// Because this is a module initializer, it ensures that the currency only gets registered once。
    /// 传入参数: witness 类型：结构体-MYCOIN    能力：drop
    /// 传入参数：ctx     类型：结构体-TxContext 能力：drop        引用：可变
    fun init(witness: MYCOIN, ctx: &mut TxContext) {
        /// function create_currency
        /// 接受范型类型 <T: drop>

        /// 传入参数: witness       类型：T（在本例中T是MYCOIN）  值：witness: MYCOIN   解释：创建货币的证人
        /// 传入参数: decimals      类型：u8                    值：6                 解释：货币的精度
        /// 传入参数: symbol        类型：vector<u8>            值：b"MYCOIN"         解释：货币的符号或标识   如：BTC
        /// 传入参数: name          类型：vector<u8>            值：b""               解释：货币的名称        如：Bit Coin
        /// 传入参数: description   类型：vector<u8>            值：b""               解释：货币的描述        如：This is bitcoin
        /// 传入参数: icon_url      类型：Option<Url>           值：option::none()    解释：货币的图标 URL
        /// 传入参数: ctx           类型：&mut TxContext        值：option::none()    解释：创建货币的证人
        /// 
        /// 返回值：TreasuryCap     <T> 解释：新货币的资金池（国库）
        /// 返回值：CoinMetadata    <T> 解释：新货币的元数据，包括货币的精度、名称、符号、描述等信息
        /// 
        /// let将TreasuryCap和CoinMetadata元组解构成两个变量
        let (treasury, metadata) = coin::create_currency(witness, 6, b"MYCOIN", b"", b"", option::none(), ctx);
        /// 元数据冻住，禁止修改
        transfer::public_freeze_object(metadata);
        /// function sender
        /// 传入参数：      self: &TxContext
        /// 返回值类型：    address
        /// 返回值：       self.sender
        /// 把treasury管理员对象的所有权交易给交易的发送者
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    /// 传入参数： treasury_cap    类型：&mut TreasuryCap<MYCOIN>   值："0xbf95702e07a2bbe2f62861a40f0e958eaeb268decd31d7aca06b7b64f9228be7"
    /// 传入参数： amount          类型：u64                        
    /// 传入参数： recipient       类型：address                    
    /// 传入参数： ctx             类型：&mut TxContext             
    /// 管理员铸币
    public entry fun mint(
        /// use sui::coin::TreasuryCap;
        /// Resource TreasuryCap
        /// 类型：&mut TreasuryCap<MYCOIN> 
        /// 解释：TreasuryCap结构体类型接受一个<T>，在本例中是<MYCOIN>范型
        /// struct TreasuryCap<T> has store, key { // TreasuryCap是一个全局对象 1 有key 2 id：全局唯一的UID
        ///     id: object::UID
        ///     total_supply: balance::Supply<T> // 传递泛型<MYCOIN> 作用：标记符，标识MYCOIN币，即MYCOIN型的total_supply
        /// }
        treasury_cap: &mut TreasuryCap<MYCOIN>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        /// 函数 铸币并交易，铸币权（铸币模版）是treasury_cap，交易给指定地址
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    /// 传入参数： treasury_cap    类型：&mut TreasuryCap<MYCOIN>   值："0xbf95702e07a2bbe2f62861a40f0e958eaeb268decd31d7aca06b7b64f9228be7"
    /// 传入参数： coin            类型：Coin<MYCOIN>               值：Coin对象的唯一id        
    /// 管理员销毁币
    /// 
    /// Resource Coin
    /// struct Coin<T> has store, key {
    ///     id: object::UID
    ///     balance: balance::Balance<T> // 传递泛型<MYCOIN> 作用：标记符，标识MYCOIN币，即MYCOIN型的balance
    /// }
    /// 
    public entry fun burn(treasury_cap: &mut TreasuryCap<MYCOIN>, coin: Coin<MYCOIN>) {
        coin::burn(treasury_cap, coin);
    }
}
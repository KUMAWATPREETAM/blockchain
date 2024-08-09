module nft_marketplace::nft {

    use aptos_token::token;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_std::simple_map;
    use std::signer::address_of;
    use std::vector;
    use std::string::{Self, String, utf8};

    const MODULE_NFT: address = @nft_marketplace;

    struct MintInfo has key {
        pool_cap: account::SignerCapability,
        minted: simple_map::SimpleMap<address, u64>,
        cid: u64
    }

    public entry fun init(admin: &signer) {
        assert!(address_of(admin) == MODULE_NFT, 1); // Ensure that the admin invoking the initialization is the correct admin

        let (pool_signer, pool_signer_cap) = account::create_resource_account(admin, b"nft_pool");

        move_to(admin, MintInfo {
            pool_cap: pool_signer_cap,
            minted: simple_map::create<address, u64>(),
            cid: 0
        });

        token::create_collection(
            &pool_signer,
            utf8(b"NFT Collection"),
            utf8(b"An exclusive NFT collection on Aptos."),
            utf8(b"https://example.com"),
            1000,
            vector<bool>[false, false, false]
        );
    }

    public entry fun mint(user: &signer, count: u64) acquires MintInfo {
        let user_addr = address_of(user);
        let mint_info_ref = borrow_global_mut<MintInfo>(MODULE_NFT);
        let cid = mint_info_ref.cid;
        assert!((cid + count) <= 1000, 3); // Ensure minting limit

        coin::transfer<AptosCoin>(user, MODULE_NFT, 150000000 * count);

        token::initialize_token_store(user);
        token::opt_in_direct_transfer(user, true);

        let pool_signer = account::create_signer_with_capability(&mint_info_ref.pool_cap);

        let i = 0;
        while (i < count) {
            let mut token_name = utf8(b"NFT #");
            string::append(&mut token_name, utf8(num_to_str(cid + i)));

            let mut token_uri = utf8(b"https://example.com/nft/");
            string::append(&mut token_uri, utf8(num_to_str(cid + i)));
            string::append(&mut token_uri, utf8(b".json"));

            let token_data_id = token::create_tokendata(
                &pool_signer,
                utf8(b"NFT Collection"),
                token_name,
                utf8(b"An exclusive NFT."),
                1,
                token_uri,
                MODULE_NFT,
                1000,
                44,
                token::create_token_mutability_config(&vector<bool>[false, false, false, false, false]),
                vector<String>[],
                vector<vector<u8>>[],
                vector<String>[]
            );
            token::mint_token_to(&pool_signer, user_addr, token_data_id, 1);
            i = i + 1;
        }

        mint_info_ref.cid = cid + count;
    }

    public fun num_to_str(num: u64): vector<u8> {
        let mut vec_data = vector::empty<u8>();
        let mut n = num;
        if n == 0 {
            vector::push_back(&mut vec_data, 48 as u8);
        }
        while (n > 0) {
            vector::push_back(&mut vec_data, (n % 10 + 48 as u8));
            n = n / 10;
        }
        vector::reverse(&mut vec_data);
        vec_data
    }
}

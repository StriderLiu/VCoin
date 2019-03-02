App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  loading: false,
  tokenPrice: 1000000000000000,
  tokensSold: 0,
  tokensAvailable: 750000,

  init: function() {
    console.log("App initialized...")
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContracts();
  },

  initContracts: function() {
    $.getJSON("VCoinTokenSale.json", function(VCoinTokenSale) {
      App.contracts.VCoinTokenSale = TruffleContract(VCoinTokenSale);
      App.contracts.VCoinTokenSale.setProvider(App.web3Provider);
      App.contracts.VCoinTokenSale.deployed().then(function(VCoinTokenSale) {
        console.log("Dapp Token Sale Address:", VCoinTokenSale.address);
      });
    }).done(function() {
      $.getJSON("VCoinToken.json", function(VCoinToken) {
        App.contracts.VCoinToken = TruffleContract(VCoinToken);
        App.contracts.VCoinToken.setProvider(App.web3Provider);
        App.contracts.VCoinToken.deployed().then(function(VCoinToken) {
          console.log("Dapp Token Address:", VCoinToken.address);
        });

        App.listenForEvents();
        return App.render();
      });
    })
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.VCoinTokenSale.deployed().then(function(instance) {
      instance.Sell({}, {
        fromBlock: 0,
        toBlock: 'latest',
      }).watch(function(error, event) {
        console.log("event triggered", event);
        App.render();
      })
    })
  },

  render: function() {
    if (App.loading) {
      return;
    }
    App.loading = true;

    var loader  = $('#loader');
    var content = $('#content');

    loader.show();
    // content.hide();

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if(err === null) {
        App.account = account;
        $('#accountAddress').html("Your Account: " + account);
      }
    })

    // Load token sale contract
    App.contracts.VCoinTokenSale.deployed().then(function(instance) {
      VCoinTokenSaleInstance = instance;
      return VCoinTokenSaleInstance.tokenPrice();
    }).then(function(tokenPrice) {
      App.tokenPrice = tokenPrice;
      $('.token-price').html(web3.fromWei(App.tokenPrice, "ether").toNumber());
      return VCoinTokenSaleInstance.tokensSold();
    }).then(function(tokensSold) {
      App.tokensSold = tokensSold.toNumber();
      $('.tokens-sold').html(App.tokensSold);
      $('.tokens-available').html(App.tokensAvailable);

      var progressPercent = (Math.ceil(App.tokensSold) / App.tokensAvailable) * 100;
      $('#progress').css('width', progressPercent + '%');

      // Load token contract
      App.contracts.VCoinToken.deployed().then(function(instance) {
        VCoinTokenInstance = instance;
        return VCoinTokenInstance.balanceOf(App.account);
      }).then(function(balance) {
        $('.dapp-balance').html(balance.toNumber());
        App.loading = false;
        loader.hide();
        content.show();
      })
    });
  },

  transferTokens: function() {
    $('#content').hide();
    $('#loader').show();
    var toAccount = $('#toAccount').val();
    var numberOfTokens = $('#numberOfTokens').val();

    App.contracts.VCoinTokenSale.deployed().then(function(instance) {
      return instance.buyTokens(numberOfTokens, {
        from: App.address,
        value: numberOfTokens * App.tokenPrice,
        gas: 500000 // Gas limit
      });
    }).then(function(result) {
      console.log("Tokens bought..." + App.contracts.VCoinToken.balanceOf(toAccount))
      $('form').trigger('reset') // reset number of tokens in form
      // Wait for Sell event
    });

    App.contracts.VCoinToken.deployed().then(function(instance) {
      return instance.transfer(toAccount, numberOfTokens, {
        from: App.account
      });
    }).then(function(result) {
      console.log("Transfer tokens...")
    });
  }
}

$(function() {
  $(window).load(function() {
    App.init();
  })
});

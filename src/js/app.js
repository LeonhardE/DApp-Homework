App = {
  web3Provider: null,
  contracts: {},

  init: async function() {
    return await App.initWeb3();
  },

  initWeb3: async function() {
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("User.json", function(gambel) {
      // Instantiate a new truffle contract from the artifact
      var UserArtifact = gambel;
      App.contracts.User = TruffleContract(UserArtifact);
      // Connect provider to interact with contract
      App.contracts.User.setProvider(App.web3Provider);

      $.getJSON('../games.json', function(data) {
        var petsRow = $('#petsRow');
        var petTemplate = $('#petTemplate');
  
        for (i = 0; i < data.length; i ++) {
          petTemplate.find('.panel-title').text(data[i].name);
          petTemplate.find('img').attr('src', data[i].picture);
          petTemplate.find('.game-price').text(data[i].price);
          petTemplate.find('.game-reward').text(data[i].reward);
          petTemplate.find('.game-home').text(data[i].home);
          petTemplate.find('.game-visitor').text(data[i].visitor);
          petTemplate.find('.game-location').text(data[i].location);
          petTemplate.find('.btn-win').attr('data-id', data[i].id);
          petTemplate.find('.btn-lose').attr('data-id', data[i].id);
          petTemplate.find('.btn-draw').attr('data-id', data[i].id);

          petsRow.append(petTemplate.html());
        }
      });
      return App.bindEvents();
    });
  },

  bindEvents: function() {

    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;
      return UserInstance.getOwner.call();
    }).then(function(owner){
      $("#contractOwner").html("Contract Owner: " + owner);
    }).catch(function(err) {
      console.log(err.message);
    });

    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;
      return UserInstance.getMoney.call();
    }).then(function(money){
      $("#accountinfo").html("Your Money: " + money);
    }).catch(function(err) {
      console.log(err.message);
    });

    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;
      return UserInstance.getName.call();
    }).then(function(name){
      if (name != "") $("#accountname").html("Your Name: " + name);
      else $("#accountname").html("Your Name: Not Set");
    }).catch(function(err) {
      console.log(err.message);
    });

    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;
      return UserInstance.getAge.call();
    }).then(function(age){
      if (age > 0) $("#accountage").html("Your Age: " + age);
      else $("#accountage").html("Your Age: Not Set");
    }).catch(function(err) {
      console.log(err.message);
    });

    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;
      return UserInstance.getteamnum.call();
    }).then(function(count){
      $("#team").html("Team Account: " + count);
    }).catch(function(err) {
      console.log(err.message);
    });

    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;
      return UserInstance.getgamenum.call();
    }).then(function(count){
      $("#game").html("Game Account: " + count);
    }).catch(function(err) {
      console.log(err.message);
    });

    $(document).on('click', '.btn-win', App.handlewin);
    $(document).on('click', '.btn-lose', App.handlelose);
    $(document).on('click', '.btn-draw', App.handledraw);
    $(document).on('click', '#submitset', App.handleSet);
  },
  handleSet: function() {
    event.preventDefault();

    var newname = $("#setname").val();
    var newage = $("#setage").val();

    var UserInstance;

    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;
      return UserInstance.setProfile(newname, newage);
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  handlewin: function() {
    var gameid = parseInt($(event.target).data('id'));
    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;

      return UserInstance.buyteamwin(gameid, 2 * gameid);
    }).catch(function(err) {
      console.log(err.message);
    });
    alert("You have bought the Game" + (gameid + 1) + "'s home team win!");
  },

  handlelose: function() {
    var gameid = parseInt($(event.target).data('id'));
    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;

      return UserInstance.buyteamlose(gameid, 2 * gameid);
    }).catch(function(err) {
      console.log(err.message);
    });
    alert("You have bought the Game" + (gameid + 1) + "'s home team lose!");
  },

  handledraw: function() {
    var gameid = parseInt($(event.target).data('id'));
    App.contracts.User.deployed().then(function(instance) {
      UserInstance = instance;

      return UserInstance.buygamedraw(gameid);
    }).catch(function(err) {
      console.log(err.message);
    });
    alert("You have bought the Game" + (gameid + 1) + " draw!");
  }

}
$(function() {
  $(window).load(function() {
    App.init();
  });
});

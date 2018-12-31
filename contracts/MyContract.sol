pragma solidity >= 0.4.0 <0.6.0;

contract User {
    struct gameinfo {
        uint id;
        string title;
        uint[2] teams;
        bool[2] win;
    }

    struct teaminfo {
        string name;
        uint id;
    }
    string private username;
    uint private age;
    uint private money;
    address private owner;
    address[] public friendlist;
    teaminfo[] public teamlist;
    gameinfo[] public gamelist;
    enum result{win, lose, draw}
    
    constructor () public {
        owner = msg.sender;
        money = 100;
        addteam(0);
        setteamname(0, "German");
        addteam(1);
        setteamname(1, "Argentina");
        addteam(2);
        setteamname(2, "Laker");
        addteam(3);
        setteamname(3, "Warriors");
        addteam(4);
        setteamname(4, "Cavaliers");
        addteam(5);
        setteamname(5, "Bulls");
        addteam(6);
        setteamname(6, "Barcelona");
        addteam(7);
        setteamname(7, "Real Madrid");
        addgame(0, 0, 1, "Game1");
        setgameresult(0, false, false);
        addgame(1, 2, 3, "Game2");
        setgameresult(1, true, false);
        addgame(2, 4, 5, "Game3");
        setgameresult(2, true, false);
        addgame(3, 6, 7, "Game4");
        setgameresult(3, true, false);
    }

    function getOwner() public view returns (address) {
        return owner;
    }
    
    modifier checkowner {
        require(owner == msg.sender, "Sender not authorized");
        _;
    }
    
    modifier checkage {
        require(age >= 18, "The owner is not an adult yet");
        _;
    }
    
    modifier checkfriend(address friendaddr) {
        require(isfriend(friendaddr), "The user is not one of the owner's friend");
        _;
    }
    
    modifier checknotfriend(address friendaddr) {
        require(!isfriend(friendaddr) && friendaddr != owner, "The user is already a friend of the owner or the owner himself");
        _;
    }

    modifier checkfriendnum(uint friendcount) {
        require(friendcount < getfriendnum(), "The number is larger than the number of friends you have.");
        _;
    }
    
    function getfriendnum() public view returns (uint) {
        return friendlist.length;
    }
    
    function isfriend(address friendaddr) public view checkowner returns (bool) {
        for (uint i = 0; i < friendlist.length; i++) {
            if (friendlist[i] == friendaddr) return true;
        }
        return false;
    }
    
    function addfriend(address newfriend) public checkowner checknotfriend(newfriend) {
        friendlist.push(newfriend);
    }
    
    function deletefriend(address friendaddr) public checkowner checkfriend(friendaddr) {
        bool flag = false;
        for (uint i = 0; i < friendlist.length - 1; i++) {
            if (flag == false) {
                if (friendlist[i] == friendaddr) {
                    flag = true;
                    friendlist[i] = friendlist[i + 1];
                }
            }
            else {
                friendlist[i] = friendlist[i + 1];
            }
        }
        friendlist.length--;
    }

    function getfriend(uint friendcount) public view checkowner checkfriendnum(friendcount) returns (address) {
        return friendlist[friendcount];
    }
    
    function checkmoney(uint amount) public view checkowner returns (bool) {
        return money >= amount;
    }
    
    function getName() public view returns (string memory) {
        return username;
    }
    
    function setProfile(string memory newName, uint newAge) public checkowner {
        username = newName;
        age = newAge;
    }
    
    function getAge() public view returns (uint) {
        return age;
    }
    
    function getMoney() public view returns (uint) {
        return money;
    }
    
    function pay(uint amount) public checkowner checkage returns (bool) {
        if (checkmoney(amount)) {
            money -= amount;
            return true;
        }
        else return false;
    }
    
    function deposit(uint amount) public checkowner {
        money += amount;
    }

    // Game part
    modifier ingame(uint gameid, uint teamid) {
        require(isingame(gameid, teamid), "The team is not involved in the game");
        _;
    }
    
    modifier teamnotexist(uint teamid) {
        require(!isteam(teamid), "The team already exist");
        _;
    }
    
    modifier teamexist(uint teamid) {
        require(isteam(teamid), "The team does not exist");
        _;
    }

    modifier gamenotexist(uint gameid) {
        require(!isgame(gameid), "The game already exist");
        _;
    }
    
    modifier gameexist(uint gameid) {
        require(isgame(gameid), "The game does not exist");
        _;
    }

    function isteam(uint teamid) public view returns (bool) {
        for (uint i = 0; i < teamlist.length; i++) {
            if (teamlist[i].id == teamid) return true;
        }
        return false;
    }

    function isgame(uint gameid) public view returns (bool) {
        for (uint i = 0; i < gamelist.length; i++) {
            if (gamelist[i].id == gameid) return true;
        }
        return false;
    }

    function isingame(uint gameid, uint teamid) public view returns (bool) {
        for (uint i = 0; i < gamelist.length; i++) {
            if (gamelist[i].id == gameid) {
                return gamelist[i].teams[0] == teamid || gamelist[i].teams[1] == teamid;
            }
        }
    }

    function addteam(uint newteamid) public teamnotexist(newteamid) {
        teaminfo memory newteam;
        newteam.id = newteamid;
        teamlist.push(newteam);
    }

    function addgame(uint gameid, uint newteam1, uint newteam2, string memory newtitle) public gamenotexist(gameid) 
                     teamexist(newteam1) teamexist(newteam2) {
        gameinfo memory newgame;
        newgame.id = gameid;
        newgame.teams[0] = newteam1;
        newgame.teams[1] = newteam2;
        newgame.title = newtitle;
        gamelist.push(newgame);
    }

    function setgameresult(uint gameid, bool win1, bool win2) public gameexist(gameid) {
        for (uint i = 0; i < gamelist.length; i++) {
            if (gamelist[i].id == gameid) {
                gamelist[i].win[0] = win1;
                gamelist[i].win[1] = win2;
            }
        }
    }
    
    function getgameresult(uint gameid, uint teamid) public view ingame(gameid, teamid) gameexist(gameid) teamexist(teamid) returns (result) {
        for (uint i = 0; i < gamelist.length; i++) {
            if (gamelist[i].id == gameid) {
                if (gamelist[i].teams[0] == teamid) {
                    if (gamelist[i].win[0] == true && gamelist[i].win[1] == false) return result.win;
                    else if (gamelist[i].win[0] == false && gamelist[i].win[1] == true) return result.lose;
                    else return result.draw;
                }
                else {
                    if (gamelist[i].win[1] == true && gamelist[i].win[0] == false) return result.win;
                    else if (gamelist[i].win[1] == false && gamelist[i].win[0] == true) return result.lose;
                    else return result.draw;
                }
            }
        }
    }
    
    function getgametitle(uint gameid) public view gameexist(gameid) returns (string memory) {
        for (uint i = 0; i < gamelist.length; i++) {
            if (gamelist[i].id == gameid) return gamelist[i].title;
        }
    }
    
    function setgametitle(uint gameid, string memory newtitle) public gameexist(gameid) {
        for (uint i = 0; i < gamelist.length; i++) {
            if (gamelist[i].id == gameid) {
                gamelist[i].title = newtitle;
            }
        }
    }
    
    function getteamname(uint teamid) public view teamexist(teamid) returns (string memory) {
        for (uint i = 0; i < teamlist.length; i++) {
            if (teamlist[i].id == teamid) return teamlist[i].name;
        }
    }
    
    function setteamname(uint teamid, string memory newname) public teamexist(teamid) {
        for (uint i = 0; i < teamlist.length; i++) {
            if (teamlist[i].id == teamid) teamlist[i].name = newname;
        }
    }

    function getteamnum() public view returns (uint) {
        return teamlist.length;
    }

    function getgamenum() public view returns (uint) {
        return gamelist.length;
    }

    // Trade
    function buyteamwin(uint gameid, uint teamid) public gameexist(gameid) teamexist(teamid) ingame(gameid, teamid) {
        if (pay(50) == true) {
            if (getgameresult(gameid, teamid) == result.win) deposit(100);
        }
    }

    function buyteamlose(uint gameid, uint teamid) public gameexist(gameid) teamexist(teamid) ingame(gameid, teamid) {
        if (pay(50) == true) {
            if (getgameresult(gameid, teamid) == result.lose) deposit(100);
        }
    }

    function buygamedraw(uint gameid) public gameexist(gameid) {
        if (pay(50) == true) {
            for (uint i = 0; i < gamelist.length; i++) {
                if (gamelist[i].id == gameid) {
                    if (getgameresult(gameid, gamelist[i].teams[0]) == result.draw) deposit(100);
                }
            }
        }
    }

}











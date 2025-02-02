import 'dart:convert';
import 'dart:typed_data';

import 'package:hex_place/services/models/friend.dart';
import 'package:hex_place/services/models/guild.dart';
import 'package:hex_place/services/models/guild_member.dart';
import 'package:hex_place/services/socket_services.dart';
import 'package:hex_place/views/user_interface/ui_views/guild_window/guild_information.dart';

class User {

  late int id;
  late String userName;
  late DateTime tileLock;
  bool verified = false;
  bool admin = false;
  late List<Friend> friends;
  Uint8List? avatar;
  Guild? guild;
  List<Guild> guildInvites = [];
  bool origin = false;

  User(this.id, this.userName, this.verified, this.friends, String? timeLock) {
    if (timeLock != null) {
      if (!timeLock.endsWith("Z")) {
        // The server has utc timestamp, but it's not formatted with the 'Z'.
        timeLock += "Z";
      }
      tileLock = DateTime.parse(timeLock).toLocal();
    } else {
      tileLock = DateTime.now();
    }
  }

  int getId() {
    return id;
  }

  String getUserName() {
    return userName;
  }

  setUsername(String username) {
    userName = username;
  }

  DateTime getTileLock() {
    return tileLock;
  }

  bool isVerified() {
    return verified;
  }

  bool isAdmin() {
    return admin;
  }

  Uint8List? getAvatar() {
    return avatar;
  }

  void setAvatar(Uint8List avatar) {
    this.avatar = avatar;
  }

  setGuildInvites(List<Guild> guildInvites) {
    this.guildInvites = guildInvites;
  }

  bool isOrigin() {
    return origin;
  }

  addGuildInvites(Guild guildInvite) {
    if (guildInvites.any((element) => element.getGuildId() == guildInvite.getGuildId())) {
      Guild existingGuild = guildInvites
          .where((element) => element.getGuildId() == guildInvite.getGuildId())
          .first;
      if (guildInvite.retrieved && !existingGuild.retrieved) {
        guildInvites.removeWhere((element) => element.getGuildId() == existingGuild.getGuildId());
      guildInvites.add(guildInvite);
        return;
      } else {
        // in all other situation we do nothing because the member is already correctly in the list.
        return;
      }
    } else {
      guildInvites.add(guildInvite);
      return;
    }
  }

  removeGuildRequests() {
    guildInvites = [];
  }

  updateTileLock(String tileLock) {
    if (!tileLock.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      tileLock += "Z";
    }
    this.tileLock = DateTime.parse(tileLock).toLocal();
  }

  List<Friend> getFriends() {
    return friends;
  }

  addFriend(Friend friend) {
    // update friend if the username is already in the list
    for (Friend f in friends) {
      if (f.getFriendId() == friend.getFriendId()) {
        if (friend.retrievedAvatar) {
          f.setAccepted(friend.isAccepted());
          f.setRequested(friend.isRequested());
          f.setFriendName(friend.getFriendName());
          f.setUnreadMessages(friend.getUnreadMessages());
          f.setFriendAvatar(friend.getFriendAvatar());
          f.retrievedAvatar = friend.retrievedAvatar;
          return;
        } else {
          // the friend already exists and maybe it's information retrieved, but it is now updated.
          // update the information except the avatar and username.
          f.setAccepted(friend.isAccepted());
          f.setRequested(friend.isRequested());
          f.setUnreadMessages(friend.getUnreadMessages());
          return;
        }
      }
    }
    // If the friend was not updated it is not in the list, so we add it to the list.
    friends.add(friend);
  }

  removeFriend(int friendId) {
    friends.removeWhere((friend) => friend.getFriendId() == friendId);
  }

  Guild? getGuild() {
    return guild;
  }

  setGuild(Guild? guild) {
    this.guild = guild;
    if (this.guild != null) {
      // We set a guild, so remove any invites or request that have been made.
      GuildInformation guildInformation = GuildInformation();
      guildInformation.guildsSendRequests = [];
      guildInformation.guildsGotRequests = [];
      removeGuildRequests();
      setMyGuildRank();
      SocketServices().enteredGuildRoom(this.guild!.getGuildId());
    }
  }

  setMyGuildRank() {
    if (guild != null) {
      for (GuildMember member in guild!.getMembers()) {
        if (member.getGuildMemberId() == id) {
          guild!.setAdministrator(false);
          if (member.getGuildMemberRank() == 0) {
            guild!.setAdministrator(true);
            guild!.setMyGuildRank("Guildmaster");
          } else if (member.getGuildMemberRank() == 1) {
            guild!.setAdministrator(true);
            guild!.setMyGuildRank("Officer");
          } else if (member.getGuildMemberRank() == 2) {
            guild!.setMyGuildRank("Merchant");
          } else {
            guild!.setMyGuildRank("Trader");
          }
          return;
        }
      }
    }
  }

  User.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    userName = json["username"];

    if (json.containsKey("verified")) {
      verified = json["verified"];
    }
    if (json.containsKey("is_admin")) {
      admin = json["is_admin"];
    }
    if (json.containsKey("friends")) {
      friends = [];
      for (var friend in json["friends"]) {
        friends.add(Friend.fromJson(friend));
      }
    } else {
      friends = [];
    }

    if (json.containsKey("tile_lock")) {
      String timeLock = json["tile_lock"];
      if (!timeLock.endsWith("Z")) {
        // The server has utc timestamp, but it's not formatted with the 'Z'.
        timeLock += "Z";
      }
      tileLock = DateTime.parse(timeLock).toLocal();
    } else {
      // If the timeLock is not present it will not be used.
      tileLock = DateTime.now();
    }

    if (json.containsKey("avatar") && json["avatar"] != null) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }

    if (json.containsKey("guild") && json["guild"] != null) {
      setGuild(Guild.fromJson(json["guild"], false));
      setMyGuildRank();
    }
    if (json.containsKey("origin")) {
      origin = json["origin"];
    }
  }

  @override
  String toString() {
    return 'User{userName: $userName}';
  }
}

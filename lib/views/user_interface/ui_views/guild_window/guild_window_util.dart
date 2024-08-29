import 'dart:convert';

import 'package:hex_place/services/auth_service_social.dart';
import 'package:hex_place/services/models/guild_member.dart';
import 'package:hex_place/services/models/user.dart';
import 'package:hex_place/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:hex_place/views/user_interface/ui_views/guild_window/guild_window_change_notifier.dart';

retrieveGuildMembers(User me) {
  if (me.getGuild() != null) {
    // Some members have been added or removed, we need to update the list
    // or we have not yet retrieved the users from the ids
    List<int> membersToRetrieve = [];
    for (GuildMember member in me.getGuild()!.getMembers()) {
      if (!member.isMemberRetrieved()) {
        membersToRetrieve.add(member.getGuildMemberId());
      }
    }
    if (membersToRetrieve.isNotEmpty) {
      AuthServiceSocial().getFriendAvatars(membersToRetrieve).then((value) {
        if (value != null) {
          for (Map<String, dynamic> guildMember in value) {
            int guildMemberId = guildMember["id"];
            String guildMemberName = guildMember["username"];
            String guildMemberAvatar = guildMember["avatar"];
            for (GuildMember member in me.getGuild()!.getMembers()) {
              if (member.getGuildMemberId() == guildMemberId) {
                member.setGuildMemberName(guildMemberName);
                member.setGuildMemberAvatar(base64Decode(guildMemberAvatar.replaceAll("\n", "")));
              }
            }
          }
          GuildWindowChangeNotifier().notify();
        }
      });
    }
  }
}

setGuildCrest(User me, GuildInformation guildInformation) {
  if (me.getGuild() != null ) {
    if (me.getGuild()!.getGuildCrest() != null) {
      guildInformation.setGuildCrest(me.getGuild()!.getGuildCrest()!);
      guildInformation.setCrestIsDefault(false);
    }
  }
}
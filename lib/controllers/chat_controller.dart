import 'package:get/get.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();
  final UserController userCon = Get.find();

  /// connectChatUser
  Future<void> connectChatUser(String userID, String userName, String userImage) async {
    final client = StreamChat.of(Get.context!).client;

    // 중복 커넥트 방지
    if (client.state.currentUser?.id == null) {
      await client.connectUser(
          User(
            id: userID.replaceAll('.', '_'),
            extraData: {
              'name': userName,
              'image': userImage,
            },
          ),
          client.devToken(userID.replaceAll('.', '_')).rawValue);
    }
  }

  /// make chat room - 한번 채팅방을 hard delete 하면 권한조정이 필요하다
  Future<Channel> createChatChannel(List<String> toChatUserIDs) async {
    final core = StreamChatCore.of(Get.context!);

    toChatUserIDs.add(core.currentUser!.id); // 주최자 포함시킴

    final channel = core.client.channel('messaging', extraData: {
      'members': toChatUserIDs,
    });
    await channel.watch(); // 없으면 생성
    return channel;
  }

  /// get all users info - 현재 유저는 제외
  Future<QueryUsersResponse> queryUsers() async {
    final client = StreamChat.of(Get.context!).client;
    final QueryUsersResponse response = await client.queryUsers(
      filter: Filter.and([
        Filter.equal('role', 'user'),
        Filter.notEqual('id', userCon.userInfo.value.userID!.replaceAll('.', '_')),
      ]),
    );
    return response;
  }

  /// chat disconnect user
  Future<void> disconnectUser() async {
    final client = StreamChat.of(Get.context!).client;
    await client.disconnectUser();
  }
}

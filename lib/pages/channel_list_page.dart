import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/common/widgets/avatar.dart';
import 'package:neptune_project/controllers/chat_controller.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:neptune_project/pages/channel_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

// ignore: must_be_immutable
class ChannelListPage extends StatelessWidget {
  ChannelListPage({Key? key}) : super(key: key);

  final UserController userCon = Get.find();
  final ChatController chatCon = Get.find();
  final RxList<String> checkedChatUsers = <String>[].obs; // 채팅할 유저 리스트 -> 채팅방 생성용

  @override
  Widget build(BuildContext context) {
    final StreamChannelListController _listController = StreamChannelListController(
      client: chatCon.client,
      filter: Filter.in_(
        'members',
        [chatCon.client.state.currentUser?.id ?? 'no_id'],
      ),
      sort: const [SortOption('last_message_at')],
      limit: 20,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Obx(() => Avatar.small(url: userCon.userInfo.value.userImage ?? 'http://placekitten.com/200/200')),
          )
        ],
      ),
      body: StreamBuilder(
        stream: StreamChat.of(context).currentUserStream,
        builder: (context, snapshot) {
          return (snapshot.data != null)
              ? StreamChannelListView(
                  controller: _listController,
                  onChannelTap: (channel) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return StreamChannel(
                            channel: channel,
                            child: const ChannelPage(),
                          );
                        },
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('Loading...', style: TextStyle(fontSize: 15)),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ///

          final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('uploadSpMessage');
          final HttpsCallableResult result = await callable();
          print('⚪ rd : ${result.data}');

          final HttpsCallable callable2 = FirebaseFunctions.instance.httpsCallable('uploadSpMessage2');
          final HttpsCallableResult result2 = await callable2({'message': 'here'});
          print('⚪ rd2 : ${result2.data}');

          ///
          checkedChatUsers.clear(); // 채팅 참여자 리셋

          Get.defaultDialog(
            title: 'Who do you want to chat?',
            titleStyle: const TextStyle(fontSize: 15),
            content: FutureBuilder(
                future: chatCon.queryUsers(),
                builder: (_, snapshot) {
                  QueryUsersResponse? data = snapshot.data as QueryUsersResponse?;
                  if (data == null) return const CupertinoActivityIndicator();

                  /// gs client member list
                  return SizedBox(
                    width: double.maxFinite,
                    height: 200,
                    child: ListView.builder(
                        itemCount: data.users.length,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          final User canChatUser = data.users[index];
                          return InkWell(
                            onTap: () {
                              /// 대화상대 선택
                              if (checkedChatUsers.contains(canChatUser.id)) {
                                checkedChatUsers.remove(canChatUser.id);
                              } else {
                                checkedChatUsers.add(canChatUser.id);
                              }
                            },
                            child: Obx(() => Container(
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: checkedChatUsers.contains(canChatUser.id)
                                        ? Colors.grey.shade300
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Avatar.medium(url: canChatUser.extraData['image'].toString()),
                                      const SizedBox(width: 20),
                                      Text(canChatUser.name),
                                    ],
                                  ),
                                )),
                          );
                        }),
                  );
                }),
            onConfirm: () {
              /// 채팅방 없으면 생성 있으면 엔터
              List<String> channelUsers = checkedChatUsers.map((element) => element.replaceAll('.', '_')).toList();

              chatCon.createChatChannel(channelUsers).then((channel) {
                Get.back(); // off defaultDialog

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return StreamChannel(
                        channel: channel,
                        child: const ChannelPage(),
                      );
                    },
                  ),
                );
              });
            },
            confirmTextColor: Colors.white,
            onCancel: () => Get.back(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

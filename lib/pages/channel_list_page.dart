import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/common/widgets/avatar.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:neptune_project/pages/channel_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChannelListPage extends StatelessWidget {
  ChannelListPage({Key? key}) : super(key: key);

  final UserController userCon = Get.isRegistered<UserController>() ? Get.find() : Get.put(UserController());

  late final _listController = StreamChannelListController(
    client: StreamChat.of(Get.context!).client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(Get.context!).currentUser!.id],
    ),
    sort: const [SortOption('last_message_at')],
    limit: 20,
  );

  @override
  Widget build(BuildContext context) {
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
        builder: (_, snapshot) {
          return snapshot.data != null
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
        onPressed: () {
          Get.defaultDialog(
            title: 'Who do you want to chat?',
            titleStyle: const TextStyle(fontSize: 15),
            content: FutureBuilder(
                future: userCon.queryUsers(),
                builder: (_, snapshot) {
                  QueryUsersResponse? data = snapshot.data as QueryUsersResponse?;
                  if (data == null) return const CupertinoActivityIndicator();

                  /// gs client member list
                  return SizedBox(
                    width: double.maxFinite,
                    height: 150,
                    child: ListView.builder(
                        itemCount: data.users.length,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          User user = data.users[index];
                          return InkWell(
                            onTap: () {
                              /// 유저 선택 -> 채팅방 없으면 생성 있으면 엔터
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Avatar.medium(url: user.extraData['image'].toString()),
                                  const SizedBox(width: 20),
                                  Text(user.name),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }),
            onCancel: () => Get.back(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

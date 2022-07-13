import 'package:flutter/material.dart';
import 'package:neptune_project/controllers/chat_controller.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChannelPage extends StatelessWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    final channelHeaderTheme = StreamChannelHeaderTheme.of(context);

    return Scaffold(
      appBar: StreamChannelHeader(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Row(
                children: [
                  StreamChannelAvatar(
                    channel: channel,
                    borderRadius: channelHeaderTheme.avatarTheme?.borderRadius,
                    constraints: channelHeaderTheme.avatarTheme?.constraints,
                  ),
                  const SizedBox(width: 10),

                  /// 대화자 추가
                  InkWell(
                    onTap: () async {
                      print('⚪ ttt ');
                      // channel.addMembers(['jinsung@nptn_io0']);

                      // final invite = ChatController.to.client.channel("messaging", extraData: {
                      //   "members": ['hurgoon@gmail_com', 'jinsung@nptn_io']
                      // });
                      // await invite.create();

                      // await channel.addMembers(
                      //   [],
                      //   Message(
                      //     text: 'hurgoon@gmail_com joined the channel.',
                      //     // id: 'hurgoon@gmail_com',
                      //   ),
                      // );
                    },
                    child: const Icon(
                      Icons.add_reaction_outlined,
                      color: Colors.black,
                      size: 43,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: const <Widget>[
          Expanded(
            child: StreamMessageListView(),
          ),
          StreamMessageInput(),
        ],
      ),
    );
  }
}

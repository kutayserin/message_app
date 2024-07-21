import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
  return MessagesNotifier(ref);
});
final loadingProvider = StateProvider<bool>((ref) => false);

class MessagesNotifier extends StateNotifier<List<Message>> {
  MessagesNotifier(this.ref) : super([]) {
    _initializeMessages();
  }

  final Ref ref;

  final Map<int, bool> _likedStatus = {};

  Future<void> _initializeMessages() async {
    state = _fetchMessages();
  }

  void toggleLike(int id) {
    _likedStatus[id] = !(_likedStatus[id] ?? false);
    state = _fetchMessages();
  }

  void updateMessages() {
    state = _fetchMessages();
  }

  List<Message> _fetchMessages() {
    return List.generate(
      5,
      (index) => Message(
        id: index,
        content: 'message_content_${index + 1}'.tr(),
        date: DateTime.now(),
        liked: _likedStatus[index] ?? false,
      ),
    );
  }
}

class Message {
  final int id;
  final String content;
  final bool liked;
  final DateTime date;

  Message({required this.id, required this.content, required this.liked, required this.date});

  Message copyWith({int? id, String? content, bool? liked, DateTime? date}) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      liked: liked ?? this.liked,
      date: date ?? this.date,
    );
  }
}
class MessagesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);
    final isLoading = ref.watch(loadingProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'daily_message'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: Container(
            margin: EdgeInsets.only(left: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.black),
              onPressed: () {
             
              },
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      MediaQuery.of(context).size.width - 56,
                      kToolbarHeight,
                      0,
                      0,
                    ),
                    items: [
                      PopupMenuItem(
                        child: Text(
                          EasyLocalization.of(context)!.currentLocale == Locale('tr', 'TR')
                              ? 'change_to_english'.tr()
                              : 'change_to_turkish'.tr(),
                        ),
                        onTap: () async {
                          final currentLocale = EasyLocalization.of(context)!.currentLocale;
                          final newLocale = currentLocale == Locale('tr', 'TR')
                              ? Locale('en', 'US')
                              : Locale('tr', 'TR');
                          
                          ref.read(loadingProvider.notifier).state = true; 
                          await context.setLocale(newLocale);
                          ref.read(messagesProvider.notifier).updateMessages();
                          ref.read(loadingProvider.notifier).state = false;
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/image_1.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (!isLoading) 
              PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: IntrinsicHeight(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.88),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'message_header'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      icon: Icon(
                                        message.liked ? Icons.favorite : Icons.favorite_border,
                                        color: message.liked ? Colors.red : Colors.white,
                                      ),
                                      onPressed: () {
                                        ref.read(messagesProvider.notifier).toggleLike(message.id);
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 32.0),
                                  Align(
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      icon: Icon(Icons.file_upload_outlined, color: Colors.white),
                                      onPressed: () {
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 52.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  'lucky_number'.tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(width: 18.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                  
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

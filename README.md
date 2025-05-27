[![Pub Version](https://img.shields.io/pub/v/chatwoot_client_sdk?color=blueviolet)](https://pub.dev/packages/chatwoot_sdk)

# Integrate Chatwoot with Flutter app

Integrate Chatwoot flutter client into your flutter app and talk to your visitors in real time. [Chatwoot](https://github.com/chatwoot/chatwoot) helps you to chat with your visitors and provide exceptional support in real time. To use Chatwoot in your flutter app, follow the steps described below.

<img src="https://user-images.githubusercontent.com/22669874/225545427-bd3fe38c-d116-4286-b542-67b03a51e2d2.jpg" alt="chatwoot screenshot" height="560"/>

## 1. Installation

Run the command below in your terminal

`flutter pub add chatwoot_sdk`

or

Add
`chatwoot_sdk:<<version>>`
to your project's [pubspec.yml](https://flutter.dev/docs/development/tools/pubspec) file. You can check [here](https://pub.dev/packages/chatwoot_sdk) for the latest version.

## 2. Getting Started

| Options        | Use case                                                                                                                                                                        | Inbox Type | Example                                                           | Known Platform Support Issues                                                                                                                                                                    |
|----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------|-------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ChatwootClient | Bare client api for building custom chat widgets.                                                                                                                               | API        | [Chatwoot Client example](#a-using-chatwoot-client)               | -                                                                                                                                                                                                |
| ChatwootDialog | Flutter Widget implementation built on the ChatwootClient                                                                                                                       | API        | [Chatwoot Dialog example](#b-using-chatwootChatDialog)            | -                                                                                                                                                                                                |
| ChatwootChat   | Also a widget implementation of ChatwootClient but presents only the Chat interface. Can be embedded in a a custom page unlike the dialog which is always presented in a dialog | API        | [Chatwoot Chat Widget example](#c-embedding-chatwootChat)         | -                                                                                                                                                                                                |
| ChatwootWidget | The chatwoot website channel widget embedded in a flutter webview                                                                                                               | Website    | [Chatwoot Webview Widget example](#d-using-chatwootWidgetwebview) | Flutter webview currently supports only  android & ios.  Adding file attachment not supported on ios.  Some known issues with previewing and downloading attached files on both Android and ios. |

## 3. How to use

### a. Using Chatwoot Client
* Create an Api inbox in Chatwoot. Refer to [Create API Channel](https://www.chatwoot.com/docs/product/channels/api/create-channel) document.
* Create your own customized chat ui and use `ChatwootClient` to load and sendMessages. Messaging events like `onMessageSent` and `onMessageReceived` will be triggered on `ChatwootCallback` argument passed when creating the client instance.


NB: This chatwoot client uses [Hive](https://pub.dev/packages/hive) for local storage.

```dart
final chatwootCallbacks = ChatwootCallbacks(
      onWelcome: (){
        print("on welcome");
      },
      onPing: (){
        print("on ping");
      },
      onConfirmedSubscription: (){
        print("on confirmed subscription");
      },
      onConversationStartedTyping: (){
        print("on conversation started typing");
      },
      onConversationStoppedTyping: (){
        print("on conversation stopped typing");
      },
      onPersistedMessagesRetrieved: (persistedMessages){
        print("persisted messages retrieved");
      },
      onMessagesRetrieved: (messages){
        print("messages retrieved");
      },
      onMessageReceived: (chatwootMessage){
        print("message received");
      },
      onMessageDelivered: (chatwootMessage, echoId){
        print("message delivered");
      },
      onMessageSent: (chatwootMessage, echoId){
        print("message sent");
      },
      onError: (error){
        print("Ooops! Something went wrong. Error Cause: ${error.cause}");
      },
    );

    ChatwootClient.create(
        baseUrl: widget.baseUrl,
        inboxIdentifier: widget.inboxIdentifier,
        user: widget.user,
        enablePersistence: widget.enablePersistence,
        callbacks: chatwootCallbacks
    ).then((client) {
        client.loadMessages();
    }).onError((error, stackTrace) {
      print("chatwoot client error $error: $stackTrace");
    });
```

#### Available Parameters

| Name              | Default | Type              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|-------------------|---------|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| baseUrl           | -       | String            | Installation url for chatwoot                                                                                                                                                                                                                                                                                                                                                                                                                      |
| inboxIdentifier   | -       | String            | Identifier for target chatwoot inbox                                                                                                                                                                                                                                                                                                                                                                                                               |
| enablePersistance | true    | bool              | Enables persistence of chatwoot client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists chatwoot client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call ChatwootClient.clearData or ChatwootClient.clearAllData<br>false - holds chatwoot client instance's data in memory and is cleared as<br>soon as chatwoot client instance is disposed<br>Setting |
| user              | null    | ChatwootUser      | Custom user details to be attached to chatwoot contact                                                                                                                                                                                                                                                                                                                                                                                             |
| callbacks         | null    | ChatwootCallbacks | Callbacks for handling chatwoot events                                                                                                                                                                                                                                                                                                                                                                                                             |


### b. Using ChatwootChatDialog
* Create an Api inbox in Chatwoot. Refer to [Create API Channel](https://www.chatwoot.com/docs/product/channels/api/create-channel) document.
* Call `ChatwootChatDialog.show` with Api inbox configuration

```dart
ChatwootChatDialog.show(
    context,
    title: "Customer Support",
    inboxIdentifier: "your-api-inbox-identifier",
    userIdentityValidationKey: "your hmac user validation key",
    baseUrl: "https://app.chatwoot.com",
    user: ChatwootUser(
        identifier: "test@test.com",
        name: "Tester test",
        email: "test@test.com",
    ),
    primaryColor: const Color(0xff258596),
    onAttachmentPressed: _handleAttachmentPressed,
    openFile: _handleOpenFile,
);
```

#### Available Parameters

| Name                          | Default | Type                              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|-------------------------------|---------|-----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| baseUrl                       | -       | String                            | Installation url for chatwoot                                                                                                                                                                                                                                                                                                                                                                                                                      |
| inboxIdentifier               | -       | String                            | Identifier for target chatwoot inbox                                                                                                                                                                                                                                                                                                                                                                                                               |
| enablePersistance             | true    | bool                              | Enables persistence of chatwoot client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists chatwoot client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call ChatwootClient.clearData or ChatwootClient.clearAllData<br>false - holds chatwoot client instance's data in memory and is cleared as<br>soon as chatwoot client instance is disposed<br>Setting |
| user                          | null    | ChatwootUser                      | Custom user details to be attached to chatwoot contact                                                                                                                                                                                                                                                                                                                                                                                             |
| primaryColor                  | blue    | Widget color                      | Widget theme color                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| All chatwoot callback methods | null    | ChatwootCallbacks                 | Callbacks for handling chatwoot events                                                                                                                                                                                                                                                                                                                                                                                                             |
| onAttachmentPressed           | null    | Future<FileAttachment> Function() | Callback for handling attach file button onPressed                                                                                                                                                                                                                                                                                                                                                                                                 |
| openFile                      | null    | void Function(String filePath)    | Callbacks for handling event where user taps to open an attachment                                                                                                                                                                                                                                                                                                                                                                                 |


### c. Embedding ChatwootChat
* Create an Api inbox in Chatwoot. Refer to [Create API Channel](https://www.chatwoot.com/docs/product/channels/api/create-channel) document.
* Initialize `ChatwootChat` with Api inbox configuration

```dart

    ChatwootChat(
        inboxIdentifier: "your-api-inbox-identifier",
        userIdentityValidationKey: "your hmac user validation key",
        baseUrl: "https://app.chatwoot.com",
        user: ChatwootUser(
            identifier: "test@test.com",
            name: "Tester test",
            email: "test@test.com",
        ),
        enablePersistence: true,
        theme: ChatwootChatTheme(primaryColor: Colors.blue,),
        onConversationIsOffline: () {},
        onConversationIsOnline: () {},
        onConversationStoppedTyping: () {},
        onConversationStartedTyping: () {},
        onAttachmentPressed: () async{return FileAttachment();},
        openFile: (filePath){},
    );
```

#### Available Parameters

| Name                          | Default | Type                               | Description                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|-------------------------------|---------|------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| baseUrl                       | -       | String                             | Installation url for chatwoot                                                                                                                                                                                                                                                                                                                                                                                                                      |
| inboxIdentifier               | -       | String                             | Identifier for target chatwoot inbox                                                                                                                                                                                                                                                                                                                                                                                                               |
| enablePersistance             | true    | bool                               | Enables persistence of chatwoot client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists chatwoot client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call ChatwootClient.clearData or ChatwootClient.clearAllData<br>false - holds chatwoot client instance's data in memory and is cleared as<br>soon as chatwoot client instance is disposed<br>Setting |
| user                          | null    | ChatwootUser                       | Custom user details to be attached to chatwoot contact                                                                                                                                                                                                                                                                                                                                                                                             |
| All chatwoot callback methods | null    | ChatwootCallbacks                  | Callbacks for handling chatwoot events                                                                                                                                                                                                                                                                                                                                                                                                             |
| onAttachmentPressed           | null    | Future<FileAttachment> Function()  | Callback for handling attach file button onPressed                                                                                                                                                                                                                                                                                                                                                                                                 |
| openFile                      | null    | void Function(String filePath)     | Callbacks for handling event where user taps to open an attachment                                                                                                                                                                                                                                                                                                                                                                                 |


### d. Using ChatwootWidget(webview)

* Create a **website channel** in chatwoot server by following the steps described here https://www.chatwoot.com/docs/channels/website
* Replace websiteToken prop and baseUrl

```dart
import 'dart:io';

import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatwoot Example"),
      ),
      body: ChatwootWidget(
        websiteToken: "websiteToken",
        baseUrl: "https://app.chatwoot.com",
        user: ChatwootUser(
          identifier: "test@test.com",
          name: "Tester test",
          email: "test@test.com",
        ),
        locale: "fr",
        closeWidget: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        },
        //attachment only works on android for now
        onAttachFile: _androidFilePicker,
        onLoadStarted: () {
          print("loading widget");
        },
        onLoadProgress: (int progress) {
          print("loading... ${progress}");
        },
        onLoadCompleted: () {
          print("widget loaded");
        },
      ),
    );
  }

  Future<List<String>> _androidFilePicker() async {
    final picker = image_picker.ImagePicker();
    final photo =
        await picker.pickImage(source: image_picker.ImageSource.gallery);

    if (photo == null) {
      return [];
    }

    final imageData = await photo.readAsBytes();
    final decodedImage = image.decodeImage(imageData);
    final scaledImage = image.copyResize(decodedImage, width: 500);
    final jpg = image.encodeJpg(scaledImage, quality: 90);

    final filePath = (await getTemporaryDirectory()).uri.resolve(
          './image_${DateTime.now().microsecondsSinceEpoch}.jpg',
        );
    final file = await File.fromUri(filePath).create(recursive: true);
    await file.writeAsBytes(jpg, flush: true);

    return [file.uri.toString()];
  }
}
```

Horray! You're done.


#### Available Parameters

| Name             | Default | Type                            | Description                                                                                            |
|------------------|---------|---------------------------------|--------------------------------------------------------------------------------------------------------|
| websiteToken     | -       | String                          | Website inbox channel token                                                                            |
| baseUrl          | -       | String                          | Installation url for chatwoot                                                                          |
| user             | -       | ChatwootUser                    | User information about the user like email, username and avatar_url                                    |
| locale           | en      | String                          | User locale                                                                                            |
| closeWidget      | -       | void Function()                 | widget close event                                                                                     |
| customAttributes | -       | dynamic                         | Additional information about the customer                                                              |
| onAttachFile     | -       | Future<List<String>> Function() | Widget Attachment event. Should return a list of File Uris Currently supported only on Android devices |
| onLoadStarted    | -       | void Function()                 | Widget load start event                                                                                |
| onLoadProgress   | -       | void Function(int)              | Widget Load progress event                                                                             |
| onLoadCompleted  | -       | void Function()                 | Widget Load completed event                                                                            |

## 4. 高级功能使用指南

### a. 变更Contact

Chatwoot SDK 支持变更联系人，您可以通过如下方式使用：

```dart
// 1. 创建新的联系人
final contact = await client.authService.createNewContact(
  inboxIdentifier,
  ChatwootUser(
    identifier: "user@example.com",
    name: "User Name",
    email: "user@example.com"
  )
);

// 2. 设置当前联系人
await client.setCurrentContact(contact);

// 3. 获取当前联系人信息
final currentContact = client.currentContact;

// 4. 更新联系人信息
final updatedContact = await client.authService.getContact();
await client.setCurrentContact(updatedContact);

// 5. 清除当前联系人
await client.clearClientData();
```

注意事项：
1. 变更联系人会清除当前会话和消息
2. 建议在变更联系人前保存重要数据
3. 确保新联系人信息完整且有效
4. 变更后需要重新创建会话

### b. 多会话管理

Chatwoot SDK 支持多会话管理，您可以通过以下方式使用：

```dart
// 1. 创建新的会话
final conversation = await client.authService.createNewConversation(
  inboxIdentifier,
  contact.contactIdentifier!
);

// 2. 设置当前会话
await client.setCurrentConversation(conversation);

// 3. 获取当前会话的消息
final messages = await client.getMessages(conversationId: conversation.id);

// 4. 发送消息到当前会话
await client.sendMessage(
  content: "Hello",
  echoId: "unique_id",
);

// 5. 切换会话
await client.setCurrentConversation(anotherConversation);
```

### b. 使用 Repository

Repository 提供了更底层的操作接口，您可以通过以下方式使用：

```dart
// 1. 获取 repository 实例
final repository = client.repository;

// 2. 获取本地存储的消息
repository.getPersistedMessages();

// 3. 从服务器获取最新消息
await repository.getMessages();

// 4. 发送消息
await repository.sendMessage(
  ChatwootNewMessageRequest(
    content: "Hello",
    echoId: "unique_id",
  )
);

// 5. 发送用户动作
repository.sendAction(ChatwootActionType.typing_on);

// 6. 发送 CSAT 调查反馈
await repository.sendCsatFeedBack(
  conversationUuid,
  SendCsatSurveyRequest(
    rating: 5,
    feedbackMessage: "Great service!"
  )
);
```

### c. 使用 AuthService

AuthService 提供了认证和会话管理相关的功能：

```dart
// 1. 获取 authService 实例
final authService = client.authService;

// 2. 创建新的联系人
final contact = await authService.createNewContact(
  inboxIdentifier,
  ChatwootUser(
    identifier: "user@example.com",
    name: "User Name",
    email: "user@example.com"
  )
);

// 3. 创建新的会话
final conversation = await authService.createNewConversation(
  inboxIdentifier,
  contact.contactIdentifier!
);

// 4. 获取联系人信息
final contactInfo = await authService.getContact();

// 5. 获取会话列表
final conversations = await authService.getConversations();
```

### d. 数据持久化

SDK 支持数据持久化，您可以通过以下方式管理数据：

```dart
// 1. 清除当前客户端实例的数据
client.clearClientData();

// 2. 清除特定客户端实例的数据
await ChatwootClient.clearData(
  baseUrl: "https://app.chatwoot.com",
  inboxIdentifier: "your-inbox-id",
  userIdentifier: "user@example.com"
);

// 3. 清除所有持久化数据
await ChatwootClient.clearAllData();
```

### e. 最佳实践

1. 会话管理：
   - 在切换会话时，记得调用 `setCurrentConversation`
   - 使用 `currentConversation` 检查当前会话状态
   - 在发送消息前确保有活动的会话

2. 数据持久化：
   - 使用 `enablePersistence` 参数控制是否启用持久化
   - 定期清理不需要的数据
   - 在应用退出时调用 `dispose` 方法

3. 错误处理：
   - 实现 `ChatwootCallbacks` 中的 `onError` 回调
   - 检查 `currentContact` 和 `currentConversation` 的状态
   - 处理网络错误和会话超时

4. 性能优化：
   - 使用 `getPersistedMessages` 快速加载本地消息
   - 使用 `getMessages` 获取最新消息
   - 适当使用 `clearClientData` 清理数据

const StreamChat = require('stream-chat').StreamChat;
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const serverClient = StreamChat.getInstance(functions.config().stream.key, functions.config().stream.secret);

// 특정 문자열(슬러쉬)이 포함된 메세지를 해당 유저의 도큐먼트안에 업로드 
exports.uploadSpMessage = functions.https.onRequest( (request, response) => {
    response.send({data : "Hello from function"});
});

exports.uploadSpMessage2 = functions.https.onCall((data, context) => {
    var message = data['message'];

    return context.auth.uid;
});

// // 유저가 파베를 지울때, 스트림 어카운트도 지워짐
// exports.deleteStreamUser = functions.auth.user().onDelete((user, context) => {
//     return serverClient.deleteUser(user.uid);
//   });
  
// // 스트림 유저 생성하고 토큰 리턴
// exports.createStreamUserAndGetToken = functions.https.onCall(async (data, context) => {
//     // 유저가 자격이 있는지 확인
//     if (!context.auth) {
//         throw new functions.https.HttpsError('failed-preconditions' , 'The functions must be called ' + 'while authenticated.');
//     } else {
//         try {
//             // 서버클라이언트로 유저 생성
//             await serverClient.upsertUser({
//                 id: context.auth.uid,
//                 name: context.auth.token.name,
//                 email: context.auth.token.email,
//                 image: context.auth.token.image,
//             });

//             // 생성하고 user auth token 리턴
//             return serverClient.createToken(context.auth.uid);
//         } catch (err) {
//             console.error(`Unable to create user with ID ${context.auth.uid} on Stream. Error ${err}`);
            
//             // HttpsError를 던져서 클라이언트가 에러 디테일을 받을 수 있게 한다
//             throw new functions.https.HttpsError('aborted', "Could not create Stream user");
//         }
//     }
// });

// // 스트림 유저 토큰 취득
// exports.getStreamUserToken = functions.https.onCall((data, context) => {
//     // 유저 자격 체크
//     if (!context.auth) {
//         // HttpsError를 던져서 클라이언트가 에러 디테일을 받을 수 있게 한다
//         throw new functions.https.HttpsError('failed-precondition', 'The function must be called ' + 'while authenticated.');
//     } else {
//         try {
//             return serverClient.createToken(context.auth.uid);
//         } catch (err) {
//             console.error(`Unable to get user token with ID ${context.auth.uid} on Stream. Reeor ${err}`);
//             // HttpsError를 던져서 클라이언트가 에러 디테일을 받을 수 있게 한다
//             throw new functions.https.HttpsError('aborted', "Could not get Stream user");
//         }
//     }
// });

// // 자격있는 유저의 스트림챗 토큰을 폐지
// exports.revokeStreamUserToken = functions.https.onCall((data, context) => {
//     // 유저 자격 체크
//     if(!context.auth) {
//         throw new functions.https.HttpsError('failed-precondition', 'The function must be called '+'while authenticated.')
//     } else {
//         try {
//             return serverClient.revokeUserToken(context.auth.uid);
//         } catch (err) {
//             console.error(`Unable to revoke user token with ID ${context.auth.uid} on Stream. Error ${err}`);
//         }
//     }
// });
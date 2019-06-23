const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();


var msgData;

exports.newSubscriberNotification = functions.firestore
    .document('Incidencias/{clientId}')
    .onCreate((snap, context) => {
        msgData = snap.data();
        admin.firestore().collection('Usuarias').where('admin','==','true').get().then((snap) => {
            var tokens = [];
            if (snap.empty) {
                console.log('No Device');
            } else {
                for (var token of snap.docs) {
                    tokens.push(token.data().token);
                }
                var payload = {
                    "notification": {
                        "title": "Nova Incidencia ",
                        "body": msgData.name + " - " + msgData.created,
                        "sound": "default"
                    },
                    "data": {
                        "sendername": msgData.name,
                        "message": 'Nova Incidencia!'
                    }
                }
                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                   return console.log('Pushed them all');
                }).catch((err) => {
                    console.log(err);
                });
            }
        return 0
    
    }).catch((err)=>{
            console.log(err);
        });
    });
    exports.newMessaegeNotification = functions.firestore
    .document('Incidencias/{clientId}/Mensajes/{messageId}')
    .onCreate((snap, context) => {
        msgData = snap.data();
        admin.firestore().collection('Usuarias').where('admin','==','true').get().then((snap) => {
            var tokens = [];
            if (snap.empty) {
                console.log('No Device');
            } else {
                for (var token of snap.docs) {
                    tokens.push(token.data().token);
                }
                var payload = {
                    "notification": {
                        "title": "From " + msgData.name,
                        "body": "Nou Missatge",
                        "sound": "default"
                    },
                    "data": {
                        "sendername": msgData.name,
                        "message": 'Nova Incidencia!'
                    }
                }
                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                   return console.log('Pushed them all');
                }).catch((err) => {
                    console.log(err);
                });
            }
        return 0
    }).catch((err)=>{
            console.log(err);
        });
    });
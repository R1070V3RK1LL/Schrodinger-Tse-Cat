var express = require('express'),
app = express();
var http = require('http').createServer(app); //récupère le module http
//const {JSDOM} = require("jsdom"); //récupère le jsdom
//const {window} = new JSDOM(""); //crée une fenêtre jsdom
//var $ = require("jquery")(window); //récupère jquery
var swig = require('swig'); //récupère le module non-standard swig qui permet d'importer un template html dans le fichier js
var PORT = 8080; //définit le port
const listeUtilisateurs = []; //Une variable globale pour gérer la liste utilisateurs
const histo = [" ", " ", " "];
var msghisto = "";
var counter = 0;
var user;
app.get('/', (req, res) => {
    res.writeHead(200, {
        'Content-Type': 'text/html'
    });
    res.write(swig.renderFile('app.tpl'));
    res.end();
});
app.use(express.static(__dirname + '/public'));
var io = require("socket.io")(http).listen(http); // -> http = running server
io.on('connection', (socket) => { //démarre la connexion, c'est-à-dire quand la page est lancée
    console.log('a user connected '); //affiche un message de connexion dans la console
    socket.on('disconnect', () => { //quand la page est rechargée/quittée
        console.log('user disconnected'); //affiche un message de déconnexion dans la console
    });
    socket.on('login', (user) => {
        console.log('user: ' + user.username + ' is with us !' + ' your email: ' + user.mail + ' is saved!'); //envoie un retour sur les données enregistrées
        console.log('You selected channel n°' + user.channel); //envoie un retour sur le channel sélectionné
        listeUtilisateurs.push(user.username); //on ajoute le nom de l'utilisateur qui s'est connecté dans la variable globale de la liste utilisateur
        console.log(listeUtilisateurs); //On affiche dans la console la liste d'utilisateur pour vérifier
        io.sockets.emit('envoiListe', listeUtilisateurs); //On envoie la liste utilisateur à tous les utilisateurs connectés
        socket.emit('myAlert', user.username, histo); //notifie qu'un utilisateur s'est connecté
        io.sockets.emit('notif', user.username);
        //L'utilisateur rejoint le salon correspond au numéro qu'il a choisi sur la page web
        if (user.channel == 1) {
            socket.join("room1");
        }
        if (user.channel == 2) {
            socket.join("room2");
        }
        if (user.channel == 3) {
            socket.join("room3");
        }
        if (user.channel == 4) {
            socket.join("room4");
        }
        if (user.channel == 5) {
            socket.join("room5");
        }
        if (user.channel == 6) {
            socket.join("room6");
        }
    });
    socket.on('message', (message, user) => { //quand un message est envoyé
        if (user === null) {
            console.log('Connectez-vous svp');
            socket.emit('error');
        } else {
            console.log('The message: "' + message + '" sent by: ' + user.username + '" on channel n°' + user.channel + ' has been received !'); //envoie un retour sur le message reçu
            counter += 1;
            var time = new Date();
            msghisto = "Envoyé à: " + time.getHours() + ":" + time.getMinutes() + ":" + time.getSeconds() + ": " + message + " par " + user.username;
            histo[counter - 1] = msghisto;
            console.log(histo);
            if (user.channel == 1) {
                io.sockets.to("room1").emit('message', message, user.username); //envoie le message à tout les utilisateurs du salon 1
            }
            if (user.channel == 2) {
                io.sockets.to("room2").emit('message', message, user.username); //envoie le message à tout les utilisateurs du salon 2
            }
            if (user.channel == 3) {
                io.sockets.to("room3").emit('message', message, user.username); //envoie le message à tout les utilisateurs du salon 3
            }
            if (user.channel == 4) {
                io.sockets.to("room4").emit('message', message, user.username); //envoie le message à tout les utilisateurs du salon 4
            }
            if (user.channel == 5) {
                io.sockets.to("room5").emit('message', message, user.username); //envoie le message à tout les utilisateurs du salon 5
            }
            if (user.channel == 6) {
                io.sockets.to("room6").emit('message', message, user.username); //envoie le message à tout les utilisateurs du salon 6
            }
        }
    });
    socket.on('deconnexion', (username) => { //quand un utilisateur se déconnecte
        console.log('user: ' + username + ' is disconnected !'); //envoie un retour sur les données enregistrées  
        //On supprime le nom de l'utilisateur qui vient de se déconnecter de la  liste d'utilisateurs
        var index = listeUtilisateurs.indexOf(username); //on récupère l'index correspond à l'utilisateur dans le tableau
        listeUtilisateurs.splice(index, 1); //On supprime du tableau l'utilisateur
        console.log(listeUtilisateurs);
        io.sockets.emit('envoiListeModifiée', listeUtilisateurs); //On envoie la liste des utilisateurs après départ d'un utilisateur
    })
});
//We make the http server listen on port 8080.
http.listen(PORT, () => {
    console.log('listening on:8080');
});
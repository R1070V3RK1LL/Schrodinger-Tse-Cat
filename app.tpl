<!DOCTYPE html>
    <html lang="fr">
        <head>
            <meta charset="utf-8">
            <title>NodeJS Chat App</title>
            <link rel="icon" href="data:,">  <!--To avoid favicon 404 errors -->
            <link rel="stylesheet" type="text/css" href="/css/app.css">
        </head>
        <body>
            <div id="login">
                <form action="" id="loginform">
                    <h1>Bienvenue</h1>
                    <p>Schrödinger'Tse Cat - Renseignez vos identifiants</p>
                    <input type="text" name="login" id="username" placeholder="Nom d'utilisateur">
                    <input type="mail" name="mail" id="mail" placeholder="E-mail">
                    <label for="channel">Choisissez un salon:</label>
                    <select id="channel" name="channel">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6</option>
                    </select>
                    <input type="submit" value="Envoyer">
                </form>
            </div>
            <div id="users">
                <p>Liste utilisateurs connectés:</p>
                <ul id="listusers"> </ul>
            </div>
            <form action="" id="deconnexion">
                <input type="submit" value="Deconnexion" id="logout" class="submit"></input>
            </form>
            <form action="" id="form">
                <input type="text" id="message" class="text" />
                <input type="submit" id="send" value="Envoyer mon message" class="submit" />
            </form>
            <div id="messages">
                <div class="message" id="msgtpl">
                    <span id="date_heure"></span>
                </div>
            </div>
            <script>
            function date_heure(id) //fonction qui permet d'afficher la date et l'heure en temps réel
            {
                var date = new Date;   
                var j = date.getDate(); //récupère la date complète
                var h = date.getHours(); //récupère les heures
                var annee = date.getFullYear(); //récupère l'année
                var month = date.getMonth(); //récupère le mois
                jour = date.getDay(); //récupère le jour
                jours = new Array('Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi');
                mois = new Array('Janvier', 'Fevrier', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Aout', 'Septembre', 'Octobre', 'Novembre', 'Decembre');
                if(h<10) //formate la date
                {
                    h = "0"+h;
                }
                var m = date.getMinutes(); 
                if(m<10) //formate la date
                {
                    m = "0"+m;
                }
                var s = date.getSeconds(); 
                if(s<10) //formate la date
                {
                    s = "0"+s;
                }
                var resultat = 'Nous sommes le '+jours[jour]+' '+j+' '+mois[month]+' '+annee+' il est '+h+':'+m+':'+s; 
                document.getElementById(id).innerHTML = resultat; //affiche le message précédent avec l'heure en temps réel dans une balise html
                setTimeout('date_heure("'+id+'");','1000'); //heure temps réel
                return date; //retourne la date comprenant l'heure courante
            }
            </script>
            <script type="text/javascript">window.onload = date_heure('date_heure')</script>
            <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
            <!-- Load the socket.io-client, which exposes an io global
            (and the endpoint GET /socket.io/socket.io.js), and then connect-->
            <script src="/socket.io/socket.io.js"></script>
            <script>
            $(function() {
                var counter=0; //initialisation du compteur de messages
                var user; //initialisation d'un utilisateur
                var username;
                // Step 2
                // I don't need to specify any URL when I call io(), since
                // it defaults to trying to connect to the host that serves the page.
                var socket = io();
                // Step 3 : send data / object
                // Retrieve data from the loggin form; the server gets is as a login events
                // -> and back to the server file to retrieve the info sent
                $('#loginform').submit(function(e) {
                    e.preventDefault(); // prevents page reloading
                    window.alert("vous êtes connecté"); //confirme que l'utilisateur est bien connecté
                    socket.emit('login', user={"username":$('#username').val(),"mail":$('#mail').val(),"channel":$('#channel option:selected').val()}); //envoie toutes les valeurs du loginform
                    username=$('#username').val(); //stocke la valeur du champ username
                    socket.username=username;
                    $('#username').val(''); //vide la valeur du champ username
                    $('#mail').val(''); //vide la valeur du champ mail
                    $('#channel').val(''); //vide la valeur du champ channel
                    console.log(socket.username); //vérifie le renvoi de la valeur du champ username
                    console.log(user.channel); //vérifie le renvoi de la valeur du champ channel
                    $('#messages').append($('<ul>').text("Salon n°"+user.channel)); //affiche le salon actuel
                    $('#listusers').append($('<li>').text(user.username)); //ajoute l'utilisateur à la liste des utilisateurs
                    $( "#loginform" ).fadeOut( "slow", function() { //fait disparaître la fenêtre de login
                    });
                    return false;
                });
                $('#form').submit(function(e) { //formulaire du message
                    e.preventDefault(); // prevents page reloading
                    socket.emit('message', $('#message').val(),user); //envoie la valeur du message
                    $('#message').val(''); //vide la valeur du champ message
                    $('#message').focus(); //"cible" le champ message
                    return false;
                });
                $('#logout').submit(function(user){ 
                    socket.emit('logout',user.username); //appelle la fonction socket.on 'logout'
                })
                $('#deconnexion').submit(function(username) {
                    //e.preventDefault(); // prevents page reloading
                    window.alert("vous êtes déconnecté"); //confirme que l'utilisateur est bien déconnecté
                    $( "#loginform" ).fadeIn( "slow", function() { //fait disparaître la fenêtre de login
                    });
                    $('#messages ul').remove(); //supprime les messages
                    console.log(socket.username);
                    socket.emit('deconnexion', socket.username); //envoie l'username
                    return false;
                });
                socket.on('myAlert', function (user,histo) { //alerte qu'un utilisateur s'est connecté et lui donne un historique de 3 messages
                    msg1=histo[histo.length-3]; //1er message
                    console.log(msg1); 
                    msg2=histo[histo.length-2]; //2eme message
                    console.log(msg2);
                    msg3=histo[histo.length-1]; //3eme message
                    console.log(msg3);
                    window.alert('3 derniers messages: '+msg1+', '+msg2+', '+msg3); //affiche les 3 derniers messages
                });
                socket.on('notif',function(user){
                    window.alert(user+' joined the chat'); //notifie les utilisateurs que l'utilisateur "user" s'est connecté
                });
                socket.on('message', function(message,user,channel){
                    if(typeof user === "undefined")
                    {
                        window.alert("ERROR 132: NOT CONNECTED"); //empêche un utilisateur non connecté d'envoyer un message
                    }
                    else{
                    counter+=1; //compte le nombre de messages envoyés    
                    var date=date_heure("date_heure"); //enregistre la date comprenant l'heure courante
                    var msg={"message":message,h:date.getHours(),m:date.getMinutes(),s:date.getSeconds(),"username":user.username}; //crée un objet message avec le message, l'heure et le nom d'utilisateur
                    if(msg.m<10){
                        $('#messages ul:nth-child(2)').append($('<li>').text("Envoyé à:"+msg.h+":0"+msg.m+":"+msg.s+":"+msg.message+" par "+user)); //envoie le message avec l'heure au format standard
                    }
                    else{
                        $('#messages ul:nth-child(2)').append($('<li>').text("Envoyé à:"+msg.h+":"+msg.m+":"+msg.s+":"+msg.message+" par "+user)); //envoie le message avec l'heure au format standard
                    }
                    }
                });
                socket.on('error',function(){ 
                    window.alert("Veuillez vous connecter");
                })
                socket.on('envoiListe',function(listeUtilisateurs){ //Reçoit la liste et la met dans listusers
                    $('#listusers').empty(); //vide la liste
                    for (var i = 0; i <= listeUtilisateurs.length - 1; i++) {
                        $('#listusers').append($('<li>').text(listeUtilisateurs[i])); //actualise la liste dans listusers
                    };
                });
                socket.on('envoiListeModifiée',function(listeUtilisateurs){ //modifie la liste une fois qu'un utilisateur s'est déconnecté
                    console.log(listeUtilisateurs); //affiche la liste
                    $('#listusers').empty(); //vide la liste
                    for (var i = 0; i <= listeUtilisateurs.length - 1; i++) {
                        $('#listusers').append($('<li>').text(listeUtilisateurs[i])); //on ajoute l'ensemble des utilisateurs à la liste ul
                    };
                });   
                });  
            </script>
        </body>
</html>

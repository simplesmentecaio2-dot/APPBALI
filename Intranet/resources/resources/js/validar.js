function checkEnter() {
    var tecla = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
    if (tecla == 13) {
        check();
    }
}

function check() {
    var pass = document.getElementById("pass").value;
    if (pass == '@sia*2020') {
        window.open('http://app.bali.com.br/diretoria/dashboard-veiculos.aspx');
    } else {

        alert("Senha incorreta! Voce digitou isso: " + pass);
    }
}

function checkcpd() {
    var pass = document.getElementById("passcpd").value;
    if (pass == '@sia*2020') {
        window.open('http://www.balisia.com.br/escala.html');
    } else {

        alert("Senha incorreta! Voce digitou isso: " + pass);
    }
}

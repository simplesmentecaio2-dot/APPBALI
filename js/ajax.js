$(function() {
   
    function dash() {
        $("#cont").load('dashboard-veiculos.aspx')
    }

    
    window.onload = function () {
        // Define a função a ser chamada e o intervalo de tempo
        setInterval(horaDeAgora, 1000);
        setInterval(dash, 5000);
    }
    // Função com o objeto e a variável de tempo
    function horaDeAgora() {
        // Cria o objeto do tipo Date
        var intervalo = new Date();

        var hora = intervalo.getHours();
        if (hora < 10) {
            hora = '0' + hora;
        }

        var minuto = intervalo.getMinutes();
        if (minuto < 10) {
            minuto = '0' + minuto;
        }

        var segundo = intervalo.getSeconds();
        if (segundo < 10) {
            segundo = '0' + segundo;
        }
        // Cria a variável que receberá as informações que serão apresentadas
        var tempo = hora + ":" + minuto + ":" + segundo;
        // Utiliza o elemento HTML com id tempo para apresentar os valores da variável tempo
        document.getElementById("tempo").innerHTML = tempo;
    }
})

//function inicio() {
//    setInterval("pisca()", 500);
//}
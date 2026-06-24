   dayName = new Array("Domingo", "Segunda-Feira", "Terça-Feira", "Quarta-Feira", "Quinta-Feira", "Sexta-Feira", "Sábado");
        monName = new Array("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro");
        now = new Date;

        function dataPorExtenso() {
            document.getElementById('data').innerHTML = dayName[now.getDay()] + " - Dia " + now.getDate() + " de " + monName[now.getMonth()] + " de " + now.getFullYear();
        }

        function addZero(valor) {
            var retorno;
            if (valor < 10) {
                retorno = "0" + valor;
                return retorno;
            } else {
                return valor;
            }
        }

        function time() {
            today = new Date();
            h = today.getHours();
            m = today.getMinutes();
            s = today.getSeconds();
            document.getElementById('hora').innerHTML = addZero(h) + ":" + addZero(m) + ":" + addZero(s);
            setTimeout('time()', 500);
        }

        function iniciar() {
            time();
            dataPorExtenso();
        }
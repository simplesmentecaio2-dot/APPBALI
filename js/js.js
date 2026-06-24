function aguarde() {
    
    $("#gif-aguarde").toggle();
    //document.getElementById('aguarde').style.display = "visible";
}

function escondeMenuLeft() {
    $('#menu-left').toggle(100);
    $('#openMenu').toggle(100);
    $('#openMenuUp').toggle(100);

}

function esconderMenuLeftMouse() {
   
    $('#menu-left').hide(100);
    $('#openMenu').hide(100);
    $('#openMenuUp').show(100);

}

function mostraresconderDiv(idDiv) {

    $(''+ idDiv +'').toggle();
    
}

function pegarPedidoDespachante(pedido) {
    //alert(pedido.id);
    document.getElementById('TabContainerProcesso_TabPanelProcessos_txtPedido').value = pedido.id;
    document.getElementById('TabContainerProcesso_TabPanelProcessos_btnConsulta').click();
}

function Mascara(obj) {
    if (obj.value.length == 4 || obj.value.length == 7 || obj.value.length == 9)
        obj.value += ".";
    if (obj.value.length == 16)
        obj.value += "-";

}

function MascaraMoeda(objTextBox, SeparadorMilesimo, SeparadorDecimal, e) {
    var sep = 0;
    var key = '';
    var i = j = 0;
    var len = len2 = 0;
    var strCheck = '0123456789';
    var aux = aux2 = '';
    var whichCode = (window.Event) ? e.which : e.keyCode;
    if (whichCode == 13) return true;
    key = String.fromCharCode(whichCode); // Valor para o código da Chave
    if (strCheck.indexOf(key) == -1) return false; // Chave inválida
    len = objTextBox.value.length;
    for (i = 0; i < len; i++)
        if ((objTextBox.value.charAt(i) != '0') && (objTextBox.value.charAt(i) != SeparadorDecimal)) break;
    aux = '';
    for (; i < len; i++)
        if (strCheck.indexOf(objTextBox.value.charAt(i)) != -1) aux += objTextBox.value.charAt(i);
    aux += key;
    len = aux.length;
    if (len == 0) objTextBox.value = '';
    if (len == 1) objTextBox.value = '0' + SeparadorDecimal + '0' + aux;
    if (len == 2) objTextBox.value = '0' + SeparadorDecimal + aux;
    if (len > 2) {
        aux2 = '';
        for (j = 0, i = len - 3; i >= 0; i--) {
            if (j == 3) {
                aux2 += SeparadorMilesimo;
                j = 0;
            }
            aux2 += aux.charAt(i);
            j++;
        }
        objTextBox.value = '';
        len2 = aux2.length;
        for (i = len2 - 1; i >= 0; i--)
            objTextBox.value += aux2.charAt(i);
        objTextBox.value += SeparadorDecimal + aux.substr(len - 2, len);
    }
    return false;
}

//Somente Números
        function SomenteNumero(e) {
            var tecla = (window.event) ? event.keyCode : e.which;
            if ((tecla > 47 && tecla < 58)) return true;
            else {
                if (tecla == 8 || tecla == 0) return true;
                else return false;
            }
        }




function selecionarLanc(obj) {

    var lanc = obj.alt;
    document.getElementById('TabContainerProcesso_TabPanelLancamento_txtLancamentoVinc').value = lanc;
    document.getElementById('TabContainerProcesso_TabPanelLancamento_txtLancamentoVinc').focus();
}

function selecionarVeic(obj) {

    var lanc = obj.alt;
    document.getElementById('TabContainerProcesso_TabPanelVeiculo_txtVincularVeiculo').value = lanc;
    document.getElementById('TabContainerProcesso_TabPanelVeiculo_txtVincularVeiculo').focus();
}


function pergunta() {
    if (document.getElementById('TabContainerProcesso_TabPanelLancamento_txtLancamentoVinc').value != '') {

        if (confirm("Deseja confirmar essa operação? \n Isso não poderá ser desfeito!!!")) {
            return true;
        } else {
            return false;
        }
    }

    else {
        alert('Informe o Lançamento.');
        return false;
    }
}

function perguntaVeic() {
    if (document.getElementById('TabContainerProcesso_TabPanelVeiculo_txtVincularVeiculo').value != '') {

        if (confirm("Deseja confirmar essa operação? \n Isso não poderá ser desfeito!!!")) {
            return true;
        } else {
            return false;
        }
    }

    else {
        alert('Informe o Chassi do Veículo.');
        return false;
    }
}


function openIncluirAudiencia() {

    $('#incluir-audiencia').show();
    document.getElementById('incluir-audiencia').style.visibility = 'visible';

}

function enviandMensagemShow() {
   
        document.getElementById('enviandMensagem').style.visibility = 'visible';
   

}

function limparTextBoxHora() {
    document.getElementById('txtHoraAudiencia').value = '';
}

function preencheTextBoxHora() {
    
    if (document.getElementById('txtHoraAudiencia').value == '') {
        document.getElementById('txtHoraAudiencia').value = '12:00';
    }
}

function CancelIncluirAudiencia() {
    document.getElementById('incluir-audiencia').style.visibility = 'hidden';
}

function CancelIncluirResumo() {
    document.getElementById('incluir-resumo-audiencia').style.visibility = 'hidden';
}


function frameTJ(obj) {
    urlFrame = obj.title;
    document.getElementById('frameTJ').src = urlFrame;
}

function frameTJPassivo(obj) {
    urlFrame = obj.title;
    document.getElementById('frameTJPassivo').src = urlFrame;
}

function hiddenDefaultAll() {
    //alert('ESC');
    $('.hiddenDefault').hide();
    //return false;
    //document.getElementsByClassName('').style.visibility = 'hidden';
}


function openIncluirResumo(obj) {

    var audiencia = obj.id;
    document.getElementById('txtIdResumoAudiencia').value = audiencia;
    $('#incluir-resumo-audiencia').show();
    document.getElementById('incluir-resumo-audiencia').style.visibility = 'visible';
}


function printDiv(divID) {
    var conteudo = document.getElementById(divID).innerHTML;
    var win = window.open();
    win.document.write(conteudo);
    win.print();
    //win.close();//Fecha após a impressão.  
}

$(document).ready(function(){
    showfunnel();
}); 

function showfunnel() {
    var data = [
        ['PROSPECT',     2500000],
        ['PROPOSAL',    1700000],
        ['NEGOTIATION', 1000000],
        ['DEAL',      500000]       
    ];
    var options = {block: {dynamicHeight: true}};
    var chart = new D3Funnel('#funnel');
    chart.draw(data, options);

}
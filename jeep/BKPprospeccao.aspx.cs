using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;
using System.Drawing;

public partial class veiculos_contrato : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
     

        //vec.chartqtde(ddlEvento2.SelectedValue.ToString(), ddlLojadashboard.SelectedValue.ToString(), out chartquantidade);


        //chartqtdediv = chartquantidade;
      
    }
    public string tabela2;
    public string tabelaVU;

    protected void btnGravar_Click(object sender, EventArgs e)
    {
        try
            {
        Veiculos vec = new Veiculos();
        string prospecao = vec.insert_prospeccao(txtCliente.Text, txtTelefone.Text, txtEmail.Text, ddlClassificacao.Text, ddlVendedor.Text, ddlLoja.Text, ddlEvento.Text,ddlequipe.Text);

        //EnviaEmail emailenvia = new EnviaEmail();
        //string email = txtEmail.Text;
        //string cliente = txtCliente.Text;
        //string vendedor = ddlVendedor.Text;
        //string evento = ddlEvento.Text;
        //string corpo = "<html><body><img src='../img/logobali.png' /><br><br>" +
        //             "<b>Teste Email...</b><br><br>" +
        //            "Mais alguma coisa.....<br></body></html>";
        //emailenvia.sendconvite(email, cliente, evento, vendedor);

        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   "alert('DADOS GRAVADOS COM SUCESSO!');", true);
            txtCliente.Text = "";
            txtTelefone.Text = "";
            txtEmail.Text = "";
            Response.Redirect("qrcodegenerator.aspx?code=" + prospecao);

           

            }
        catch 
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                       "alert('DADOS GRAVADOS COM SUCESSO!');", true);
                txtCliente.Text = "";
                txtTelefone.Text = "";
                txtEmail.Text = "";
            }

        //string arquivo = @"c:\imagem.jpg";

      

        //MailMessage message = new MailMessage("emailRemetente@algo.com.br", "destinatario@algo.com.br");
        //message.Subject = "Contato";
        //message.Body = corpo;
        //message.IsBodyHtml = true;

        //Attachment attachment = new Attachment(arquivo);
        //message.Attachments.Add(attachment);

        //SmtpClient mailClient = new SmtpClient("smtp.algo.com.br");

        //mailClient.Send(message); 

    }

    protected void btnProcessar_Click(object sender, EventArgs e)
    {
        Veiculos vec = new Veiculos();
        string qtdequente, qtdefrio, qtdetotal, qtdeseminteresse, chartquantidade, qtdefluxo,qtdevendacarro;
        vec.select_prospeccao_quente(ddlEvento2.Text, ddlLojadashboard.Text, out qtdequente);
        vec.select_prospeccao_frio(ddlEvento2.Text, ddlLojadashboard.Text, out qtdefrio);
        vec.select_prospeccao_total(ddlEvento2.Text, ddlLojadashboard.Text, out qtdetotal);
        vec.select_prospeccao_seminteresse(ddlEvento2.Text, ddlLojadashboard.Text, out qtdeseminteresse);
        vec.select_prospeccao_fluxo(ddlEvento2.Text, ddlLojadashboard.Text, out qtdefluxo);
        vec.select_prospeccao_vendacarro(ddlEvento2.Text, ddlLojadashboard.Text, out qtdevendacarro);
        
        
        lblvendacarro.Text = qtdevendacarro;
        lblquentes.Text = qtdequente;
        lblfrios.Text = qtdefrio;
        lblqtde.Text = qtdetotal;
        lblseminteresse.Text = qtdeseminteresse;
        lblFluxo.Text = qtdefluxo;
       


    }
    
    protected void btnequipes_Click(object sender, EventArgs e)
    {

    }
    protected void btnProcessar4_Click(object sender, EventArgs e)
    {

    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        Veiculos vec = new Veiculos();
        string tabela;
        vec.select_Tab_Consultaprospeccao(out tabela);
        tabela2 = tabela;

    }
}
   
    
    

    



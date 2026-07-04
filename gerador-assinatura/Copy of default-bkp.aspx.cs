using NReco.ImageGenerator;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ImageFormat = NReco.ImageGenerator.ImageFormat;

public partial class veiculos_Pint_Contrato : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected void btnConvert_Click(object sender, EventArgs e)
    {
        string tel = "";
        string cel = "";

        //Verificando se tem telefone ou celular para adicionar legenda
        if (this.txtTel.Value != null && !this.txtTel.Value.Equals(""))
        {
            tel = "Tel.:" + ValorHtml(this.txtTel.Value);
        }
        if (this.txtCel.Value != null && !this.txtCel.Value.Equals(""))
        {
            cel = "Cel.:" + ValorHtml(this.txtCel.Value);
        }
        string empresa = EmpresaSegura();

        var html = String.Format(@"<meta http-equiv='content-type' content='text/html; charset=utf-8'/>
                                 <link rel='preconnect' href='https://fonts.gstatic.com'/>
                                 <link href='https://fonts.googleapis.com/css2?family=Roboto:wght@400;900&display=swap' rel='stylesheet'/>
                                 <link href='https://app.bali.com.br/gerador-assinatura/resources/css/style.css' rel='stylesheet'/>
                                
                                 <div id='assinatura' style='width: 280px; height: 150px;'>
                                      <div style='width: 100%; height: 55px;'>
                                          <img src='https://app.bali.com.br/gerador-assinatura/resources/headers/" + empresa + @".png' />
                                      </div>
                                      <strong>
                                          <div id='nomeImp' class='test' style='text-transform:uppercase;'> " + ValorHtml(this.txtNome.Value) + @" </div>
                                      </strong>
                                      <div style='width: 100%; height: 8px;'></div>
                                      <div id='funcaoImp'  class='test'> " + ValorHtml(this.txtFuncao.Value) + @" </div>
                                      <div style='width: 100%; height: 2px;'></div>
                                      <div id='telImp' class='test'> " + tel + @" </div>
                                      <div style='width: 100%; height: 2px;'></div>
                                      <div id='celImp' class='test'>" + cel + @"</div>
                                 </div> ");

        var htmlToImageConv = new HtmlToImageConverter();
        htmlToImageConv.Width = 280;
        htmlToImageConv.Height = 155;
        var jpegBytes = htmlToImageConv.GenerateImage(html, ImageFormat.Png.ToString());

        MemoryStream memstr = new MemoryStream(jpegBytes);

        System.Drawing.Image img = System.Drawing.Image.FromStream(memstr, true, true);

        string nomeArquivo = "assinatura-" + NomeArquivoSeguro(this.txtNome.Value) + ".png";
        string pastaDestino = Path.GetFullPath(Server.MapPath("./created/"));
        string filePath = Path.GetFullPath(Path.Combine(pastaDestino, nomeArquivo));
        if (!filePath.StartsWith(pastaDestino, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Caminho de assinatura inválido.");
        }

        img.Save(filePath);
        //Fazendo Download da imagem
        Response.ContentType = "Application/png";
        Response.AppendHeader("Content-Disposition", "attachment; filename=" + nomeArquivo);
        Response.AddHeader("Refresh", "10");
        Response.TransmitFile(filePath);
        Response.End();


    }

    private string ValorHtml(string valor)
    {
        return HttpUtility.HtmlEncode((valor ?? "").Trim());
    }

    private string NomeArquivoSeguro(string valor)
    {
        string nome = Regex.Replace((valor ?? "").Trim(), @"[^A-Za-z0-9_-]+", "-").Trim('-');
        if (String.IsNullOrEmpty(nome))
        {
            nome = "assinatura";
        }

        return nome.Length > 60 ? nome.Substring(0, 60) : nome;
    }

    private string EmpresaSegura()
    {
        string empresa = (ddlEmpresa.Value ?? "").Trim().ToLowerInvariant();
        switch (empresa)
        {
            case "jeep":
            case "fiat":
            case "byd":
            case "grupobali":
                return empresa;
            default:
                return "grupobali";
        }
    }
}

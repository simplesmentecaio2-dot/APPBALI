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
       
        string telBack = "";
        string imgrodape = "style='background-image:url(https://app.bali.com.br/gerador-assinatura/resources/headers/jeepRodapeG.png)'";
        //  adicionado 12/11/2024
        string ddd = "";
        // /adicionado 12/11/2024
        //Verificando se tem telefone ou celular para adicionar legenda
        if (this.txtTel.Value != null && !this.txtTel.Value.Equals(""))
        {
            tel = "Tel.:" + ValorHtml(this.txtTel.Value);
        }
        





        //adicionando icone no rodape
        string empresa = EmpresaSegura();
        if (empresa.Equals("jeep"))
        {
           
                telBack = imgrodape;
            
            
           
        }


        var htmlToImageConv = new HtmlToImageConverter();
        htmlToImageConv.Width = 220;
        if (empresa.Equals("jeep"))
        {
            htmlToImageConv.Width = 194;

        }


        htmlToImageConv.Height = 155;

        // adicionado 12/11/2024
        if (empresa.Equals("grupobali"))
        {
            htmlToImageConv.Width = 600;
            htmlToImageConv.Height = 110;
        }
        // /adicionado 12/11/2024

        //<link rel='preconnect' href='https://fonts.gstatic.com'/>
        //<link href='https://fonts.googleapis.com/css2?family=Roboto:wght@400;900&display=swap' rel='stylesheet'/>

        var html = String.Format(@"<meta http-equiv='content-type' content='text/html; charset=utf-8'/>
                                 
				                <link href='https://app.bali.com.br/gerador-assinatura/resources/css/font.css' rel='stylesheet'/>
                                 <link href='https://app.bali.com.br/gerador-assinatura/resources/css/style.css' rel='stylesheet'/>
                                
                                 <div id='assinatura' style='width: " + htmlToImageConv.Width + @"px; height: 150px;'>
                                      <div style='width: 100%; height: 55px;'>
                                          <img src='https://app.bali.com.br/gerador-assinatura/resources/headers/" + empresa + @".png' />
                                      </div>
                                      <strong>
                                          <div id='nomeImp' class='test' style='text-transform:uppercase;'> " + ValorHtml(this.txtNome.Value) + @" </div>
                                      </strong>
                                      <div style='width: 100%; height: 8px;'></div>
                                      <div id='funcaoImp'  class='test'> " + ValorHtml(this.txtFuncao.Value) + @" </div>
                                      <div style='width: 100%; height: 2px;'></div>
                                      <div id='telImp' class='test' " + telBack + "> " + tel + @" </div>
                                      <div style='width: 100%; height: 2px;'></div>
                                 </div> ");

        // adicionado 12/11/2024
        var htmlGrupoBali = String.Format(
            @"<!DOCTYPE html>
                <html>
                <head>
                <link href='https://app.bali.com.br/gerador-assinatura/resources/css/style_grupo.css' rel='stylesheet'/>
                <style>
                  
                </style>
                </head>      
                <body>
                <div class='assinatura-grupo-bali'>
                    <span class='nome-grupo-bali'>
                    {0}
                    </span>
                    <span class='cargo-grupo-bali'>
                    {1}
                    </span>
                    <span class='ddd-grupo-bali'>
                    {2}
                    </span>
                    <span class='telefone-grupo-bali'>
                    {3}
                    </span>
                </div>
                </body>
                </html> ", ValorHtml(this.txtNome.Value), ValorHtml(this.txtFuncao.Value), ValorHtml(this.txtDDD.Value), ValorHtml(this.txtTel.Value));

        if (empresa.Equals("grupobali"))
        {

            html = htmlGrupoBali;
        }
        // /adicionado 12/11/2024

        // var jpegBytes = htmlToImageConv.GenerateImage(html, ImageFormat.Png.ToString()); melhorar qualidade da imagem
        var jpegBytes = htmlToImageConv.GenerateImage(html, ImageFormat.Png);




        MemoryStream memstr = new MemoryStream(jpegBytes);
        var imgHighRes = System.Drawing.Image.FromStream(memstr, true, true);

        //Salvando imagem
        var finalImage = new Bitmap(imgHighRes.Width, imgHighRes.Height);
        using (Graphics g = Graphics.FromImage(finalImage))
        {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;
            g.DrawImage(imgHighRes, new Rectangle(0, 0, imgHighRes.Width, imgHighRes.Height));
        };

        string nomeArquivo = "assinatura-" + NomeArquivoSeguro(this.txtNome.Value) + ".png";
        string pastaDestino = Path.GetFullPath(Server.MapPath("./created/"));
        string filePath = Path.GetFullPath(Path.Combine(pastaDestino, nomeArquivo));
        if (!filePath.StartsWith(pastaDestino, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Caminho de assinatura inválido.");
        }

        finalImage.Save(filePath, System.Drawing.Imaging.ImageFormat.Png);
        // System.Drawing.Image img = System.Drawing.Image.FromStream(memstr, true, true);

        // img.Save(Server.MapPath("./created/assinatura-" + this.txtNome.Value + ".png"));
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

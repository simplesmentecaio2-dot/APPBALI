using NReco.ImageGenerator;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
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
            tel = "Tel.:" + this.txtTel.Value;
        }
        





        //adicionando icone no rodape
        if (ddlEmpresa.Value.Equals("jeep"))
        {
           
                telBack = imgrodape;
            
            
           
        }


        var htmlToImageConv = new HtmlToImageConverter();
        htmlToImageConv.Width = 220;
        if (ddlEmpresa.Value.Equals("jeep"))
        {
            htmlToImageConv.Width = 194;

        }


        htmlToImageConv.Height = 155;

        // adicionado 12/11/2024
        if (ddlEmpresa.Value.Equals("grupobali"))
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
                                          <img src='https://app.bali.com.br/gerador-assinatura/resources/headers/" + this.ddlEmpresa.Value + @".png' />
                                      </div>
                                      <strong>
                                          <div id='nomeImp' class='test' style='text-transform:uppercase;'> " + this.txtNome.Value + @" </div>
                                      </strong>
                                      <div style='width: 100%; height: 8px;'></div>
                                      <div id='funcaoImp'  class='test'> " + this.txtFuncao.Value + @" </div>
                                      <div style='width: 100%; height: 2px;'></div>
                                      <div id='telImp' class='test' " + telBack + "> " + tel + @" </div>
                                      <div style='width: 100%; height: 2px;'></div>
                                 </div> ");

        // adicionado 12/11/2024
        var htmlGrupoBali = String.Format(
            @"<!DOCTYPE html>
                <html>
                <head>
		<meta http-equiv='content-type' content='text/html; charset=utf-8'/>
		<meta charset='UTF-8'>
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
                </html> ", this.txtNome.Value, this.txtFuncao.Value, this.txtDDD.Value, this.txtTel.Value);

        if (ddlEmpresa.Value.Equals("grupobali"))
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

        string filePath = Server.MapPath("./created/assinatura-" + this.txtNome.Value + ".png");
        finalImage.Save(filePath, System.Drawing.Imaging.ImageFormat.Png);
        // System.Drawing.Image img = System.Drawing.Image.FromStream(memstr, true, true);

        // img.Save(Server.MapPath("./created/assinatura-" + this.txtNome.Value + ".png"));
        //Fazendo Download da imagem
        Response.ContentType = "Application/png";
        Response.AppendHeader("Content-Disposition", "attachment; filename=assinatura-" + this.txtNome.Value + ".png");
        Response.AddHeader("Refresh", "10");
        Response.TransmitFile(Server.MapPath("./created/assinatura-" + this.txtNome.Value + ".png"));
        Response.End();

    }
}
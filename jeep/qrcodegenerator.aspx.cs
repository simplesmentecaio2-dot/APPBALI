using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;
using System.Drawing;
using System.IO;
using QRCoder;

public partial class veiculos_contrato : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string code = ObterCodigoSeguro();
        bool codigoEncontrado = false;
        if (!String.IsNullOrEmpty(code))
        {
            string cliente, vendedor, loja, equipe, evento, data;
            Veiculos vec = new Veiculos();
            try
            {
                vec.select_prospeccao_qrcode(code, out cliente, out vendedor, out loja, out equipe, out evento, out data);
                lblCliente.Text = TextoSeguro(cliente);
                lblvendedor.Text = TextoSeguro(vendedor);
                lblloja.Text = TextoSeguro(loja);
                lblequipe.Text = TextoSeguro(equipe);
                lblevento.Text = TextoSeguro(evento);
                codigoEncontrado = true;
            }
            catch
            {
                lblCliente.Text = "Código não localizado.";
            }
        }
        else
        {
            lblCliente.Text = "Código inválido.";
        }

        if (!codigoEncontrado)
        {
            return;
        }


        QRCodeGenerator qrGenerator = new QRCodeGenerator();
        QRCodeGenerator.QRCode qrcode = qrGenerator.CreateQrCode("https://app.bali.com.br/jeep/confirmafluxo.aspx?id=" + HttpUtility.UrlEncode(code), QRCodeGenerator.ECCLevel.Q);
        System.Web.UI.WebControls.Image imgQRcode = new System.Web.UI.WebControls.Image();
        imgQRcode.Height = 200;
        imgQRcode.Width = 200;

        using (Bitmap bitmap = qrcode.GetGraphic(20))
        {
            using (MemoryStream ms = new MemoryStream())
            {
                bitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
                byte[] byteimage = ms.ToArray();
                imgQRcode.ImageUrl = "data:image/png;base64," + Convert.ToBase64String(byteimage);
            }
            PHQRCode.Controls.Add(imgQRcode);
        }
      
    }
   

   

    
    
    protected void btnequipes_Click(object sender, EventArgs e)
    {

    }
    protected void btnProcessar4_Click(object sender, EventArgs e)
    {

    }

    private string ObterCodigoSeguro()
    {
        string code = (Request.QueryString["code"] ?? "").Trim();
        int numero;
        return Int32.TryParse(code, out numero) && numero > 0 ? numero.ToString() : "";
    }

    private string TextoSeguro(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
    }
}
   
    
    

    



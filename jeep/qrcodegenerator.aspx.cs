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
        string code = "";
        if (Request.QueryString["code"] != null)
        {
            code = Request.QueryString["code"].ToString();
            string cliente, vendedor, loja, equipe,evento;
            Veiculos vec = new Veiculos();
            vec.select_prospeccao_qrcode(code, out cliente, out vendedor, out loja, out equipe,out evento);
            lblCliente.Text = cliente;
            lblvendedor.Text = vendedor;
            lblloja.Text = loja;
            lblequipe.Text = equipe;
            lblevento.Text = evento;

        }
        else
        {
            
        }
       

        
        QRCodeGenerator qrGenerator = new QRCodeGenerator();
        QRCodeGenerator.QRCode qrcode = qrGenerator.CreateQrCode("http://app.bali.com.br/veiculos/confirmafluxo.aspx?id=" + code, QRCodeGenerator.ECCLevel.Q);
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
}
   
    
    

    



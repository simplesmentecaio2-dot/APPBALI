using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_Seminovos_Painel_de_Controle : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null)
        {
            lblUsuario.Text = Session["usuario"].ToString();
            lblTipo.Text = Session["tipo"].ToString();


        }
        else
        {
            Response.Redirect("../Login.aspx");
        }
        Veiculos vec = new Veiculos();
        Lista_VU = vec.select_estoque_VU_Painel();
    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        try
        {
            // tirar codigo html do nome do arquivo
            //achar a solução para o fileupload #################################
            //string fileName = (FileUpload1.PostedFile.FileName);
            //string srcPath = fileName;
        
            //string srcPath = fileName.ToString();
            if (FileUpload1.FileName != "")
            {
                string uploadPath = Server.MapPath("~\\veiculos\\img-veiculos\\");
                FileUpload1.SaveAs(uploadPath + txtCodVec.Text + ".jpg");
                //FileUpload1.SaveAs(uploadPath + FileUpload1.FileName);
                string pth = Server.MapPath("~\\veiculos\\img-veiculos\\" + txtCodVec.Text + ".jpg");

                //Redefine altura e largura da imagem e Salva o arquivo + prefixo 

                Redefinir.Resize(pth, pth, 440, 340);
                Veiculos vec = new Veiculos();
                vec.inser_img_VU(txtCodVec.Text);
                //Page_Load(sender, e);
                //ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                //                                                                  "alert('Imagem inserida com sucesso!');", true);
            }

            else
            {
                Page_Load(sender, e);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                              "alert('Nenhuma imagem Selecionada!');", true);
            }
        }
        catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                              "alert('Falha ao carregar imagem!');", true);
        }
    }

    public string Lista_VU;
    protected void Button2_Click(object sender, EventArgs e)
    {
        //Page_Load(sender, e);
        //ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
        //                                                                      "alert('Nenhuma imagem Selecionada!');", true);
    }
}
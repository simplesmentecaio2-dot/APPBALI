using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text.RegularExpressions;

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
                string codigoVeiculo = (txtCodVec.Text ?? "").Trim();
                if (!Regex.IsMatch(codigoVeiculo, @"^[A-Za-z0-9_-]{1,40}$"))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                              "alert('Código do veículo inválido para upload de imagem.');", true);
                    return;
                }

                if (FileUpload1.PostedFile.ContentLength <= 0 || FileUpload1.PostedFile.ContentLength > 5242880)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                              "alert('Imagem inválida ou maior que 5 MB.');", true);
                    return;
                }

                string extensao = Path.GetExtension(FileUpload1.FileName).ToLowerInvariant();
                if (extensao != ".jpg" && extensao != ".jpeg" && extensao != ".png")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                              "alert('Envie apenas imagem JPG ou PNG.');", true);
                    return;
                }

                string uploadPath = Server.MapPath("~\\veiculos\\img-veiculos\\");
                string pth = Path.GetFullPath(Path.Combine(uploadPath, codigoVeiculo + ".jpg"));
                if (!pth.StartsWith(Path.GetFullPath(uploadPath), StringComparison.OrdinalIgnoreCase))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                              "alert('Caminho de upload inválido.');", true);
                    return;
                }

                try
                {
                    using (System.Drawing.Image.FromStream(FileUpload1.PostedFile.InputStream))
                    {
                    }
                    FileUpload1.PostedFile.InputStream.Position = 0;
                }
                catch
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                              "alert('Arquivo enviado não é uma imagem válida.');", true);
                    return;
                }

                FileUpload1.SaveAs(pth);
                //FileUpload1.SaveAs(uploadPath + FileUpload1.FileName);

                //Redefine altura e largura da imagem e Salva o arquivo + prefixo

                Redefinir.Resize(pth, pth, 440, 340);
                Veiculos vec = new Veiculos();
                vec.inser_img_VU(codigoVeiculo);
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

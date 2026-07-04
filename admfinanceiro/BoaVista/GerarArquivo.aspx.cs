using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

public partial class admfinanceiro_Comissao_geral : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
      
    }

    protected void GerarArquivo_Click(object sender, EventArgs e)
    {
        try
        {
            using (FileStream fs = File.Create(@"C:\boavista\ArquivoEnvio.txt"))
            {

                using (StreamWriter sw = new StreamWriter(fs))
                {
                    for (int i = 0; i <= 1000; i++)
                    {
                        sw.Write("Texto adicionado ao exemplo!" + i.ToString() + "\r\n");
                    }
                }
            }
        }
        catch(SystemException)
        {
            Response.Write("Não foi possível gerar o arquivo agora.");
        }
    }
}

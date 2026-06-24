using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class rafael : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

    protected void btnGerar_Click(object sender, EventArgs e)
    {
    }

    //public void loadFolder(GridView gv_arquivos, String folder)
    //{

    //    DirectoryInfo pasta = new DirectoryInfo(folder);
    //    DirectoryInfo[] subPastas = pasta.GetDirectories();
    //    FileInfo[] arquivos = pasta.GetFiles();

    //    DataTable dt = new DataTable();

    //    dt.Columns.Add("Nome"); dt.Columns.Add("Tamanho"); dt.Columns.Add("Tipo"); dt.Columns.Add("Modificado"); dt.Columns.Add("Action");
    //    if (folder != "")
    //    {
    //        DataRow dr1 = dt.NewRow();
    //        dr1["Nome"] = "../";
    //        dr1["Tamanho"] = "";
    //        dr1["Tipo"] = "";
    //        dr1["Modificado"] = "";
    //        dr1["Action"] = "";

    //        dt.Rows.Add(dr1);
    //    }
    //    foreach (DirectoryInfo dir in subPastas)
    //    {
    //        DataRow dr = dt.NewRow();
    //        dr["Nome"] = "/" + dir.Name;
    //        dr["Tamanho"] = "-";
    //        dr["Tipo"] = "Diretório";
    //        dr["Modificado"] = dir.LastWriteTime.ToString("dd/MM/yyyy");
    //        dr["Action"] = "";

    //        dt.Rows.Add(dr);
    //    }

    //    foreach (FileInfo file in arquivos)
    //    {
    //        DataRow dr = dt.NewRow();
    //        dr["Nome"] = file.Name;
    //        dr["Tamanho"] = Convert.ToString(file.Length / 1024) + " kb";
    //        dr["Tipo"] = file.Extension;
    //        dr["Modificado"] = file.LastWriteTime.ToString("dd/MM/yyyy");
    //        dr["Action"] = "<b>" + file.Name + "</b>";

    //        dt.Rows.Add(dr);
    //    }



    //    gv_arquivos.DataSource = dt;
    //    gv_arquivos.DataBind();

    //}
}
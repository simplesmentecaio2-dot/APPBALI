using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Summary description for AdmFinanceiro
/// </summary>
public class Jeep :Dao2
{
    public void select_dadosentrega(string pedido,string loja, out string cliente, out string veiculo, out string chassi, out string cor, out string placa, out string vendedor, out double valor, out string ano, out string nota)
    {
        Conexao2();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon2;
        oCmd.CommandText = "APP..jeep_select_recibo_desconto";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@pedido", SqlDbType.VarChar).Value = pedido;
        oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = loja;
        SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        cliente = odr["Cliente"].ToString();
        veiculo = odr["Veículo"].ToString();
        chassi = odr["Chassi"].ToString();
        cor = odr["Cor"].ToString();
        placa = odr["Placa"].ToString();
        vendedor = odr["Vendedor"].ToString();
        valor = Convert.ToDouble(odr["valor"].ToString());
        // valor = odr["valor"].ToString();
        ano = odr["Ano / Modelo"].ToString();
        nota = odr["Nota Fiscal"].ToString();

        FecharConexao2();

    }
    public void select_dadosentrega_jeep(string pedido, string loja,

        out string cliente,
        out string chassi,
        out string placa,
        out string cor,
        out string vendedor,
        out string veiculo,
        out string Pendencias,
        out double valor,
        // out DateTime DataPagamento,
        out string banco,
        out string observacao)
    {
        Conexao2();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon2;
        oCmd.CommandText = "APP..jeep_select_autorizacao_saida";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@pedido", SqlDbType.VarChar).Value = pedido;
        oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = loja;
        SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();

        cliente = odr["Cliente"].ToString();
        chassi = odr["Chassi"].ToString();
        placa = odr["placa"].ToString();
        cor = odr["cor"].ToString();
        vendedor = odr["Vendedor"].ToString();
        veiculo = odr["veículo"].ToString();
        Pendencias = odr["Pendencias"].ToString();
        valor = Convert.ToDouble(odr["Valor"].ToString());
        //DataPagamento = Convert.ToDateTime(odr["DataPagamento"]);
        banco = odr["Banco"].ToString();
        observacao = odr["Observação"].ToString();


        FecharConexao2();

    }
}

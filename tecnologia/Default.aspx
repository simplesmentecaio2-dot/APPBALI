<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="tecnologia_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Tecnologia | Bali App</title>
    <link href="../css/bali-tecnologia.css?v=20260627-tech01" rel="stylesheet" />
</head>
<body class="bali-tech-page">
    <form id="form1" runat="server" autocomplete="off">
        <header class="tech-topbar">
            <a class="tech-brand" href="../Default.aspx" aria-label="Voltar para a p&aacute;gina inicial">
                <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="tech-user">
                <span>&Aacute;rea restrita</span>
                <strong><asp:Label ID="lblUsuario" runat="server" /></strong>
                <small>Perfil: <asp:Label ID="lblTipo" runat="server" /></small>
            </div>
            <nav class="tech-actions" aria-label="A&ccedil;&otilde;es r&aacute;pidas">
                <a href="../Default.aspx">In&iacute;cio</a>
                <a href="../login.aspx?sair=1">Sair</a>
            </nav>
        </header>

        <main class="tech-main">
            <section class="tech-hero">
                <div>
                    <span class="tech-eyebrow">Central de acesso</span>
                    <h1>Tecnologia</h1>
                    <p>Administre sistemas, usu&aacute;rios, permiss&otilde;es e arquivos t&eacute;cnicos do grupo Bali em um &uacute;nico painel.</p>
                </div>
                <label class="tech-search" for="techSearchCards">
                    <span>Buscar atalho, &aacute;rea ou link</span>
                    <input id="techSearchCards" type="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Ex.: usu&aacute;rios, sistemas, arquivos" />
                </label>
            </section>

            <section class="tech-grid" aria-label="Atalhos de tecnologia">
                <a class="tech-card" href="sistemas.aspx" data-search="sistemas cadastro url imagem permissoes tecnologia">
                    <span class="tech-card-icon"><img src="../img/app-icons/tecnologia.svg" alt="" /></span>
                    <span class="tech-card-body">
                        <span>Cat&aacute;logo</span>
                        <strong>Sistemas</strong>
                        <small>Consulte os sistemas cadastrados e os destinos usados no controle de acesso.</small>
                    </span>
                    <span class="tech-card-action">Abrir</span>
                </a>

                <a class="tech-card is-green" href="usuarios.aspx" data-search="usuarios permissoes perfil acesso senha cadastro">
                    <span class="tech-card-icon"><img src="../img/app-icons/crm.svg" alt="" /></span>
                    <span class="tech-card-body">
                        <span>Permiss&otilde;es</span>
                        <strong>Usu&aacute;rios</strong>
                        <small>Cadastre, consulte e ajuste acessos por sistema e perfil operacional.</small>
                    </span>
                    <span class="tech-card-action">Gerenciar</span>
                </a>

                <a class="tech-card is-red" href="download.aspx" data-search="arquivos importantes downloads bibliotecas instaladores codigos">
                    <span class="tech-card-icon"><img src="../img/app-icons/entrega.svg" alt="" /></span>
                    <span class="tech-card-body">
                        <span>Suporte</span>
                        <strong>Arquivos importantes</strong>
                        <small>Acesse instaladores, bibliotecas e documentos de apoio da &aacute;rea t&eacute;cnica.</small>
                    </span>
                    <span class="tech-card-action">Ver arquivos</span>
                </a>
            </section>

            <div id="techEmptyCards" class="tech-empty" hidden>Nenhum atalho encontrado para a busca informada.</div>
        </main>
    </form>
    <script src="../js/bali-tecnologia.js?v=20260627-tech01"></script>
</body>
</html>

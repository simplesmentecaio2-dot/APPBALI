<%@ Page Language="C#" AutoEventWireup="true" CodeFile="download.aspx.cs" Inherits="rafael" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Arquivos importantes | Tecnologia</title>
    <link href="../css/bali-tecnologia.css?v=20260627-tech01" rel="stylesheet" />
</head>
<body class="bali-tech-page">
    <form id="form1" runat="server" autocomplete="off">
        <header class="tech-topbar">
            <a class="tech-brand" href="Default.aspx" aria-label="Voltar para tecnologia">
                <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="tech-user">
                <span>Tecnologia</span>
                <strong><asp:Label ID="lblUsuario" runat="server" /></strong>
                <small>Perfil: <asp:Label ID="lblTipo" runat="server" /></small>
            </div>
            <nav class="tech-actions" aria-label="Ações rápidas">
                <a href="Default.aspx">Voltar</a>
                <a href="../login.aspx?sair=1">Sair</a>
            </nav>
        </header>

        <main class="tech-main">
            <section class="tech-hero">
                <div>
                    <span class="tech-eyebrow">Downloads</span>
                    <h1>Arquivos importantes</h1>
                    <p>Materiais técnicos, instaladores e referências usados para suporte interno.</p>
                </div>
                <label class="tech-search" for="techSearchFiles">
                    <span>Buscar arquivo</span>
                    <input id="techSearchFiles" type="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Ex.: bibliotecas, Kaspersky, código" />
                </label>
            </section>

            <section class="tech-file-list" aria-label="Arquivos disponíveis">
                <a class="tech-file" href="../Bibliotecas%20e%20exemplos.rar" data-search="bibliotecas exemplos rar desenvolvimento suporte">
                    <span class="tech-panel-kicker">Pacote</span>
                    <strong>Bibliotecas e exemplos.rar</strong>
                    <small>Arquivos de apoio para desenvolvimento e manutenção.</small>
                    <span class="tech-card-action">Baixar</span>
                </a>

                <a class="tech-file" href="Arquivos/ksos19.0.0.1088apt_15121.exe" data-search="kaspersky instalador exe segurança ksos">
                    <span class="tech-panel-kicker">Instalador</span>
                    <strong>KSOS 19.0.0.1088 APT</strong>
                    <small>Executável de instalação para suporte técnico autorizado.</small>
                    <span class="tech-card-action">Baixar</span>
                </a>

                <a class="tech-file" href="Arquivos/codigo.txt" data-search="codigo código txt referencia suporte">
                    <span class="tech-panel-kicker">Referência</span>
                    <strong>codigo.txt</strong>
                    <small>Arquivo textual de consulta rápida da equipe de tecnologia.</small>
                    <span class="tech-card-action">Abrir</span>
                </a>
            </section>

            <div id="techEmptyFiles" class="tech-empty" hidden>Nenhum arquivo encontrado para a busca informada.</div>
        </main>
    </form>
    <script src="../js/bali-tecnologia.js?v=20260627-tech01"></script>
</body>
</html>

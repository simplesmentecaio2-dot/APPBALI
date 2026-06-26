<%@ Page Language="C#" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="ramais_login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Login | Ramais</title>
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, Helvetica, sans-serif;
            color: #172033;
            background: #07101f;
        }

        .ramais-login-page {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            padding: 48px;
            background:
                linear-gradient(90deg, rgba(5, 13, 28, .86) 0%, rgba(7, 16, 31, .68) 44%, rgba(7, 16, 31, .14) 100%),
                url("images/login-ramais-bg.png") center center / cover no-repeat;
        }

        .ramais-login-card {
            width: min(420px, 100%);
            padding: 34px;
            border: 1px solid rgba(255, 255, 255, .18);
            border-radius: 18px;
            background: rgba(255, 255, 255, .93);
            box-shadow: 0 26px 80px rgba(0, 0, 0, .38);
            backdrop-filter: blur(18px);
        }

        .ramais-login-brand {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 28px;
        }

        .ramais-login-mark {
            width: 48px;
            height: 48px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 14px;
            color: #fff;
            font-weight: 900;
            letter-spacing: .08em;
            background: linear-gradient(135deg, #0f766e, #111827);
        }

        .ramais-login-brand span {
            display: block;
            color: #627089;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .16em;
            text-transform: uppercase;
        }

        .ramais-login-brand strong {
            display: block;
            margin-top: 4px;
            color: #111827;
            font-size: 22px;
        }

        .ramais-login-copy {
            margin: -8px 0 22px;
            color: #5f6c82;
            font-size: 14px;
            line-height: 1.55;
        }

        .ramais-login-field {
            display: block;
            margin-bottom: 16px;
            color: #4b5870;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .08em;
            text-transform: uppercase;
        }

        .ramais-login-field input {
            width: 100%;
            height: 48px;
            margin-top: 8px;
            padding: 0 14px;
            border: 1px solid #d8e0ef;
            border-radius: 12px;
            color: #172033;
            background: #fff;
            font-size: 15px;
            outline: none;
            transition: border-color .2s ease, box-shadow .2s ease;
        }

        .ramais-login-field input:focus {
            border-color: #0f766e;
            box-shadow: 0 0 0 4px rgba(15, 118, 110, .14);
        }

        .ramais-login-button {
            width: 100%;
            height: 48px;
            margin-top: 8px;
            border: 0;
            border-radius: 12px;
            color: #fff;
            background: linear-gradient(135deg, #0f766e, #172033);
            font-weight: 900;
            letter-spacing: .04em;
            cursor: pointer;
        }

        .ramais-login-button:hover {
            filter: brightness(1.05);
        }

        .ramais-login-links {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-top: 18px;
            font-size: 13px;
        }

        .ramais-login-links a {
            color: #0f766e;
            font-weight: 800;
            text-decoration: none;
        }

        .ramais-login-message {
            margin-bottom: 18px;
            padding: 12px 14px;
            border-radius: 12px;
            color: #991b1b;
            background: #fee2e2;
            font-size: 13px;
            font-weight: 700;
        }

        @media (max-width: 720px) {
            .ramais-login-page {
                align-items: flex-end;
                padding: 22px;
            }

            .ramais-login-card {
                padding: 26px;
                border-radius: 16px;
            }

            .ramais-login-links {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" autocomplete="off">
        <main class="ramais-login-page">
            <section class="ramais-login-card" aria-label="Login do sistema de Ramais">
                <div class="ramais-login-brand">
                    <span class="ramais-login-mark">R</span>
                    <div>
                        <span>Grupo Bali</span>
                        <strong>Ramais</strong>
                    </div>
                </div>

                <p class="ramais-login-copy">Acesse a consulta e manuten&ccedil;&atilde;o dos contatos internos por loja, setor e colaborador.</p>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="ramais-login-message" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>

                <label class="ramais-login-field">Usu&aacute;rio
                    <input id="txtUsuario" runat="server" type="text" autocomplete="username" placeholder="Digite seu usu&aacute;rio" />
                </label>

                <label class="ramais-login-field">Senha
                    <input id="txtSenha" runat="server" type="password" autocomplete="current-password" placeholder="Digite sua senha" />
                </label>

                <asp:Button ID="btnLogin" runat="server" CssClass="ramais-login-button" Text="Entrar" OnClick="btnLogin_Click" />

                <div class="ramais-login-links">
                    <a href="../alterarSenha.aspx?voltar=/RAMAIS/login.aspx">Alterar senha</a>
                    <a href="../Intranet/index.html">Voltar para intranet</a>
                </div>
            </section>
        </main>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="ci_login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Login | Comunicacao Interna</title>
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, Helvetica, sans-serif;
            color: #172033;
            background: #08111f;
        }

        .ci-login-page {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            padding: 48px;
            background:
                linear-gradient(90deg, rgba(4, 10, 20, .82) 0%, rgba(8, 17, 31, .66) 44%, rgba(8, 17, 31, .16) 100%),
                url("images/login-ci-bg.png") center center / cover no-repeat;
        }

        .ci-login-card {
            width: min(420px, 100%);
            padding: 34px;
            border: 1px solid rgba(255, 255, 255, .18);
            border-radius: 18px;
            background: rgba(255, 255, 255, .92);
            box-shadow: 0 26px 80px rgba(0, 0, 0, .38);
            backdrop-filter: blur(18px);
        }

        .ci-login-brand {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 28px;
        }

        .ci-login-mark {
            width: 48px;
            height: 48px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 14px;
            color: #fff;
            font-weight: 900;
            letter-spacing: .08em;
            background: linear-gradient(135deg, #1d4ed8, #111827);
        }

        .ci-login-brand span {
            display: block;
            color: #627089;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .16em;
            text-transform: uppercase;
        }

        .ci-login-brand strong {
            display: block;
            margin-top: 4px;
            color: #111827;
            font-size: 22px;
        }

        .ci-login-field {
            display: block;
            margin-bottom: 16px;
            color: #4b5870;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .08em;
            text-transform: uppercase;
        }

        .ci-login-field input {
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

        .ci-login-field input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 4px rgba(37, 99, 235, .12);
        }

        .ci-login-button {
            width: 100%;
            height: 48px;
            margin-top: 8px;
            border: 0;
            border-radius: 12px;
            color: #fff;
            background: linear-gradient(135deg, #1d4ed8, #172033);
            font-weight: 900;
            letter-spacing: .04em;
            cursor: pointer;
        }

        .ci-login-button:hover {
            filter: brightness(1.05);
        }

        .ci-login-links {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-top: 18px;
            font-size: 13px;
        }

        .ci-login-links a {
            color: #1d4ed8;
            font-weight: 800;
            text-decoration: none;
        }

        .ci-login-message {
            margin-bottom: 18px;
            padding: 12px 14px;
            border-radius: 12px;
            color: #991b1b;
            background: #fee2e2;
            font-size: 13px;
            font-weight: 700;
        }

        @media (max-width: 720px) {
            .ci-login-page {
                align-items: flex-end;
                padding: 22px;
            }

            .ci-login-card {
                padding: 26px;
                border-radius: 16px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" autocomplete="off">
        <main class="ci-login-page">
            <section class="ci-login-card" aria-label="Login da Comunicacao Interna">
                <div class="ci-login-brand">
                    <span class="ci-login-mark">CI</span>
                    <div>
                        <span>Grupo Bali</span>
                        <strong>Comunicacao Interna</strong>
                    </div>
                </div>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="ci-login-message" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>

                <label class="ci-login-field">Usuario
                    <input id="txtUsuario" runat="server" type="text" autocomplete="username" placeholder="Digite seu usuario" />
                </label>

                <label class="ci-login-field">Senha
                    <input id="txtSenha" runat="server" type="password" autocomplete="current-password" placeholder="Digite sua senha" />
                </label>

                <asp:Button ID="btnLogin" runat="server" CssClass="ci-login-button" Text="Entrar" OnClick="btnLogin_Click" />

                <div class="ci-login-links">
                    <a href="../alterarSenha.aspx?voltar=/CI/login.aspx">Alterar senha</a>
                    <a href="../Intranet/index.html">Voltar para intranet</a>
                </div>
            </section>
        </main>
    </form>
</body>
</html>

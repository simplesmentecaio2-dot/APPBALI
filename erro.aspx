<%@ Page Language="C#" %>
<!doctype html>
<html lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Erro no processamento</title>
    <style>
        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
            font-family: Arial, sans-serif;
            background: #f5f7fb;
            color: #111827;
        }

        main {
            width: min(520px, calc(100% - 32px));
            padding: 30px;
            text-align: center;
            background: #fff;
            border: 1px solid #dbe3ee;
            border-radius: 10px;
            box-shadow: 0 20px 55px rgba(15, 23, 42, .08);
        }

        h1 {
            margin: 0 0 12px;
            font-size: 24px;
        }

        p {
            margin: 0 0 22px;
            color: #475569;
            line-height: 1.5;
        }

        button,
        a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 42px;
            padding: 0 18px;
            border: 0;
            border-radius: 8px;
            color: #fff;
            background: #111827;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <main>
        <h1>N&atilde;o foi poss&iacute;vel concluir a solicita&ccedil;&atilde;o</h1>
        <p>Tente novamente em instantes. Se o problema continuar, acione a TI do Grupo Bali.</p>
        <button type="button" onclick="history.length > 1 ? history.back() : location.href='/'">Voltar</button>
    </main>
</body>
</html>

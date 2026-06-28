(function (window, document) {
    "use strict";

    var timerId = null;
    var hooksInstalled = false;
    var storageKey = "bali.sessionTimer.expiresAt";
    var state = {
        timeoutSeconds: 900,
        expiresAt: 0,
        loginUrl: "/login.aspx",
        renewUrl: "/sessao-renovar.aspx",
        renewing: false
    };

    function init(config) {
        if (!config) return;

        state.timeoutSeconds = parseInt(config.timeoutSeconds, 10) || 900;
        state.expiresAt = parseInt(config.expiresAt, 10) || (Date.now() + state.timeoutSeconds * 1000);
        state.loginUrl = config.loginUrl || state.loginUrl;
        state.renewUrl = config.renewUrl || state.renewUrl;

        ensureCard();
        installHooks();
        publishExpiration(state.expiresAt);

        if (!timerId) {
            timerId = window.setInterval(render, 1000);
        }

        render();
    }

    function ensureCard() {
        if (document.getElementById("bali-session-timer")) return;

        injectStyles();

        var card = document.createElement("div");
        card.id = "bali-session-timer";
        card.className = "bali-session-timer";
        card.setAttribute("role", "status");
        card.setAttribute("aria-live", "polite");
        card.innerHTML =
            '<div class="bali-session-timer__body">' +
                '<span class="bali-session-timer__dot" aria-hidden="true"></span>' +
                '<div class="bali-session-timer__text">' +
                    '<span class="bali-session-timer__label">Sess\u00e3o ativa</span>' +
                    '<strong class="bali-session-timer__time">15:00</strong>' +
                '</div>' +
                '<button class="bali-session-timer__button" type="button">Renovar</button>' +
            '</div>';

        document.body.appendChild(card);

        var button = card.querySelector(".bali-session-timer__button");
        if (button) {
            button.onclick = function () {
                if (remainingSeconds() <= 0) {
                    window.location.href = state.loginUrl;
                    return;
                }

                renewSession();
            };
        }
    }

    function injectStyles() {
        if (document.getElementById("bali-session-timer-style")) return;

        var style = document.createElement("style");
        style.id = "bali-session-timer-style";
        style.type = "text/css";
        style.appendChild(document.createTextNode(
            ".bali-session-timer{position:fixed;right:18px;bottom:18px;z-index:2147483000;font-family:Arial,Helvetica,sans-serif;color:#14213d;}" +
            ".bali-session-timer__body{display:flex;align-items:center;gap:10px;min-width:214px;padding:10px 12px;border:1px solid rgba(81,103,145,.22);border-radius:12px;background:rgba(255,255,255,.94);box-shadow:0 14px 35px rgba(15,23,42,.14);backdrop-filter:blur(10px);}" +
            ".bali-session-timer__dot{width:10px;height:10px;border-radius:999px;background:#19a974;box-shadow:0 0 0 5px rgba(25,169,116,.12);flex:0 0 auto;}" +
            ".bali-session-timer__text{display:flex;flex-direction:column;line-height:1.1;min-width:70px;}" +
            ".bali-session-timer__label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.04em;color:#60708d;}" +
            ".bali-session-timer__time{font-size:20px;font-weight:800;color:#16213a;margin-top:3px;letter-spacing:0;font-variant-numeric:tabular-nums;}" +
            ".bali-session-timer__button{border:1px solid rgba(81,103,145,.22);border-radius:999px;background:#f8fafc;color:#34415d;font-size:12px;font-weight:800;padding:7px 10px;cursor:pointer;white-space:nowrap;}" +
            ".bali-session-timer__button:hover{background:#eef4ff;color:#172a4d;}" +
            ".bali-session-timer.is-warning .bali-session-timer__dot{background:#f59e0b;box-shadow:0 0 0 5px rgba(245,158,11,.15);}" +
            ".bali-session-timer.is-critical .bali-session-timer__dot{background:#dc2626;box-shadow:0 0 0 5px rgba(220,38,38,.14);}" +
            ".bali-session-timer.is-expired .bali-session-timer__body{border-color:rgba(220,38,38,.28);}" +
            ".bali-session-timer.is-expired .bali-session-timer__label{color:#b91c1c;}" +
            ".bali-session-timer.is-expired .bali-session-timer__button{background:#b91c1c;color:#fff;border-color:#b91c1c;}" +
            ".bali-session-timer.is-renewing .bali-session-timer__button{opacity:.65;pointer-events:none;}" +
            "@media (max-width:640px){.bali-session-timer{right:10px;left:10px;bottom:10px}.bali-session-timer__body{min-width:0;justify-content:space-between}.bali-session-timer__time{font-size:18px}}" +
            "@media print{.bali-session-timer{display:none!important}}"
        ));

        document.head.appendChild(style);
    }

    function render() {
        var card = document.getElementById("bali-session-timer");
        if (!card) return;

        var seconds = remainingSeconds();
        var label = card.querySelector(".bali-session-timer__label");
        var time = card.querySelector(".bali-session-timer__time");
        var button = card.querySelector(".bali-session-timer__button");

        card.className = "bali-session-timer";
        if (seconds <= 0) {
            card.className += " is-expired is-critical";
            if (label) label.textContent = "Sess\u00e3o expirada";
            if (time) time.textContent = "00:00";
            if (button) button.textContent = "Entrar";
            return;
        }

        if (seconds <= 60) {
            card.className += " is-critical";
        } else if (seconds <= 120) {
            card.className += " is-warning";
        }

        if (state.renewing) {
            card.className += " is-renewing";
        }

        if (label) label.textContent = "Sess\u00e3o ativa";
        if (time) time.textContent = format(seconds);
        if (button) button.textContent = state.renewing ? "Renovando" : "Renovar";
    }

    function remainingSeconds() {
        return Math.max(0, Math.ceil((state.expiresAt - Date.now()) / 1000));
    }

    function format(totalSeconds) {
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return pad(minutes) + ":" + pad(seconds);
    }

    function pad(value) {
        return value < 10 ? "0" + value : String(value);
    }

    function renewFromNow(timeoutSeconds) {
        var seconds = parseInt(timeoutSeconds, 10) || state.timeoutSeconds;
        state.timeoutSeconds = seconds;
        publishExpiration(Date.now() + seconds * 1000);
        render();
    }

    function publishExpiration(expiresAt) {
        state.expiresAt = expiresAt;
        try {
            window.localStorage.setItem(storageKey, String(expiresAt));
        } catch (ignore) {
        }
    }

    function renewSession() {
        if (state.renewing) return;

        state.renewing = true;
        render();

        fetch(state.renewUrl + (state.renewUrl.indexOf("?") >= 0 ? "&" : "?") + "_=" + Date.now(), {
            credentials: "same-origin",
            cache: "no-store"
        })
            .then(function (response) {
                if (!response.ok) throw new Error("Sess\u00e3o indispon\u00edvel");
                return response.json();
            })
            .then(function (data) {
                if (!data || !data.ok) throw new Error("Sess\u00e3o indispon\u00edvel");
                renewFromNow(data.timeoutSeconds || state.timeoutSeconds);
            })
            .catch(function () {
                window.location.href = state.loginUrl;
            })
            .then(function () {
                state.renewing = false;
                render();
            });
    }

    function installHooks() {
        if (hooksInstalled) return;
        hooksInstalled = true;

        window.addEventListener("storage", function (event) {
            if (event.key !== storageKey || !event.newValue) return;
            var expiresAt = parseInt(event.newValue, 10);
            if (expiresAt && expiresAt > state.expiresAt) {
                state.expiresAt = expiresAt;
                render();
            }
        });

        installAspNetAjaxHook();
        installFetchHook();
        installXhrHook();
    }

    function installAspNetAjaxHook() {
        try {
            if (!window.Sys || !Sys.WebForms || !Sys.WebForms.PageRequestManager) return;
            var manager = Sys.WebForms.PageRequestManager.getInstance();
            manager.add_endRequest(function () {
                renewFromNow(state.timeoutSeconds);
            });
        } catch (ignore) {
        }
    }

    function installFetchHook() {
        if (!window.fetch) return;
        var originalFetch = window.fetch;

        window.fetch = function () {
            var requestUrl = arguments[0];
            return originalFetch.apply(this, arguments).then(function (response) {
                if (response && response.ok && isDynamicSameOrigin(requestUrl)) {
                    renewFromNow(state.timeoutSeconds);
                }
                return response;
            });
        };
    }

    function installXhrHook() {
        if (!window.XMLHttpRequest) return;
        var originalOpen = XMLHttpRequest.prototype.open;
        var originalSend = XMLHttpRequest.prototype.send;

        XMLHttpRequest.prototype.open = function (method, url) {
            this.__baliSessionTimerUrl = url;
            return originalOpen.apply(this, arguments);
        };

        XMLHttpRequest.prototype.send = function () {
            try {
                this.addEventListener("loadend", function () {
                    if (this.status >= 200 && this.status < 400 && isDynamicSameOrigin(this.__baliSessionTimerUrl)) {
                        renewFromNow(state.timeoutSeconds);
                    }
                });
            } catch (ignore) {
            }

            return originalSend.apply(this, arguments);
        };
    }

    function isDynamicSameOrigin(url) {
        try {
            if (url && typeof url === "object" && url.url) {
                url = url.url;
            }

            var parsed = new URL(url, window.location.href);
            if (parsed.origin !== window.location.origin) return false;
            var path = parsed.pathname.toLowerCase();
            return path.indexOf(".aspx") >= 0 || path.indexOf(".asmx") >= 0 || path.indexOf(".ashx") >= 0;
        } catch (ignore) {
            return false;
        }
    }

    window.BaliSessionTimer = {
        init: init,
        renew: renewSession
    };
})(window, document);

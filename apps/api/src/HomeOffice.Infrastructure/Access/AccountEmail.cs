using System.Text.Json;
using HomeOffice.Application.Access;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using MimeKit;
using Microsoft.Extensions.Logging;

namespace HomeOffice.Infrastructure.Access;

public sealed class AccountEmail(IConfiguration config, IHostEnvironment environment, TimeProvider clock, ILogger<AccountEmail> logger) : IAccountEmail
{
    public async Task SendAsync(string email, string purpose, string code)
    {
        var development = environment.IsDevelopment() || environment.IsEnvironment("Testing");
        var localSmtp = config["Email:Transport"] == "LocalSmtp";
        if (localSmtp && (!development || !System.Net.IPAddress.TryParse(config["Email:Host"], out var address) ||
            !System.Net.IPAddress.IsLoopback(address) || !(email.EndsWith(".example", StringComparison.OrdinalIgnoreCase) || email.EndsWith(".invalid", StringComparison.OrdinalIgnoreCase))))
            throw new EmailDeliveryException();
        if (development && !localSmtp)
        {
            var folder = config["Email:CaptureDirectory"] ?? Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "HomeOfficeReservation", "email");
            Directory.CreateDirectory(folder);
            if (!OperatingSystem.IsWindows()) File.SetUnixFileMode(folder, UnixFileMode.UserRead | UnixFileMode.UserWrite | UnixFileMode.UserExecute);
            // No HTTP inbox, tokens in query strings, application logging or external delivery in development.
            var path = Path.Combine(folder, $"{clock.GetUtcNow():yyyyMMddHHmmssfff}-{Guid.NewGuid():N}.json");
            await File.WriteAllTextAsync(path, JsonSerializer.Serialize(new { email, purpose, code, issuedAtUtc = clock.GetUtcNow() }));
            if (!OperatingSystem.IsWindows()) File.SetUnixFileMode(path, UnixFileMode.UserRead | UnixFileMode.UserWrite);
            return;
        }
        var stage = "prepare";
        try
        {
            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse(config["Email:From"] ?? throw new InvalidOperationException("SMTP sender must be configured.")));
            message.To.Add(MailboxAddress.Parse(email));
            message.Subject = purpose == "activate" ? "Ativar conta HomeOffice" : "Recuperar acesso HomeOffice";
            message.Body = new TextPart("plain")
            {
                Text = $"Na aplicação HomeOffice, escolha {(purpose == "activate" ? "Ativar conta" : "Repor palavra-passe")} e introduza este código:\n\n{code}\n\nSe não solicitou esta operação, ignore esta mensagem."
            };
            using var smtp = new MailKit.Net.Smtp.SmtpClient();
            smtp.Timeout = 10000;
            using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(10));
            stage = "connect";
            await smtp.ConnectAsync(config["Email:Host"]!, config.GetValue("Email:Port", 587), localSmtp ? SecureSocketOptions.None : SecureSocketOptions.StartTls, timeout.Token);
            stage = "authenticate";
            if (!localSmtp) await smtp.AuthenticateAsync(config["Email:Username"]!, config["Email:Password"]!, timeout.Token);
            stage = "send";
            await smtp.SendAsync(message, timeout.Token);
            stage = "disconnect";
            await smtp.DisconnectAsync(true, timeout.Token);
        }
        catch (Exception error)
        {
            // SMTP exception messages can contain recipients. Record no message, token, credentials or recipient.
            logger.LogError("Account email delivery failed at {Stage}; failure type {FailureType}.", stage, error.GetType().Name);
            throw new EmailDeliveryException();
        }
    }
}
